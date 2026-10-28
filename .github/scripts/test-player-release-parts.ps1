$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-release-parts.ps1')
$project=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$githubRoot=[IO.Path]::GetFullPath((Join-Path $project '.github'))
$scratch=[IO.Path]::GetFullPath((Join-Path $githubRoot ('.parts-test-'+[guid]::NewGuid().ToString('N'))))
function Assert-Fails([scriptblock]$Action,[string]$ExpectedMessage){
 $failed=$false
 try {& $Action}catch {$failed=$true;if($_.Exception.Message -notlike ('*'+$ExpectedMessage+'*')){throw}}
 if(-not $failed){throw ('Expected failure: '+$ExpectedMessage)}
}
try {
 foreach($file in @('player-release-parts.ps1','publish-player-0.16.14.ps1','test-player-release-parts.ps1')){
  $tokens=$null;$parseErrors=$null
  $null=[Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot $file),[ref]$tokens,[ref]$parseErrors)
  if($parseErrors.Count){throw ($parseErrors|Out-String)}
 }
 New-Item -ItemType Directory -Path $scratch|Out-Null
 Add-Type -AssemblyName System.IO.Compression
 $memory=[IO.MemoryStream]::new()
 $zip=[IO.Compression.ZipArchive]::new($memory,[IO.Compression.ZipArchiveMode]::Create,$true)
 try {
  $entry=$zip.CreateEntry('fixture.txt',[IO.Compression.CompressionLevel]::NoCompression)
  $entry.LastWriteTime=[DateTimeOffset]::new(2000,1,1,0,0,0,[TimeSpan]::Zero)
  $stream=$entry.Open()
  try {$bytes=[Text.Encoding]::UTF8.GetBytes('Exact synthetic CI ZIP bytes, reconstructed from ordered public parts.');$stream.Write($bytes,0,$bytes.Length)}finally{$stream.Dispose()}
 }finally{$zip.Dispose()}
 $expected=$memory.ToArray();$memory.Dispose();$sha=Get-PlayerReleaseSHA256 $expected
 $chunks=@{};$parts=@();$offset=0
 foreach($length in @(31,47,($expected.Length-78))){
  $chunk=[byte[]]::new($length);[Array]::Copy($expected,$offset,$chunk,0,$length)
  $blob=([string]($parts.Count+1))*40
  $chunks[$blob]=$chunk
  $parts+=,[pscustomobject]@{blob=$blob;bytes=$length;sha256=(Get-PlayerReleaseSHA256 $chunk)}
  $offset+=$length
 }
 $reader={param($part);return ,([byte[]]$chunks[[string]$part.blob])}
 $output=Join-Path $scratch 'exact.zip'
 Join-PlayerReleaseParts $parts $expected.LongLength $sha $output $reader
 if([Convert]::ToBase64String([IO.File]::ReadAllBytes($output)) -cne [Convert]::ToBase64String($expected)){throw 'Synthetic ZIP reconstruction changed bytes.'}
 Assert-Fails {Join-PlayerReleaseParts $parts $expected.LongLength $sha $output $reader} ''
 $reversed=@($parts[2],$parts[1],$parts[0])
 Assert-Fails {Join-PlayerReleaseParts $reversed $expected.LongLength $sha (Join-Path $scratch 'reversed.zip') $reader} 'SHA256 mismatch'
 $tampered={param($part);$chunk=([byte[]]$chunks[[string]$part.blob]).Clone();$chunk[0]=$chunk[0] -bxor 1;return ,$chunk}
 Assert-Fails {Join-PlayerReleaseParts $parts $expected.LongLength $sha (Join-Path $scratch 'tampered.zip') $tampered} 'part size or SHA256 mismatch'
 Assert-Fails {Assert-PlayerReleaseParts @() 0 'PENDING'} 'PENDING'
 $oversized=@([pscustomobject]@{blob=('a'*40);bytes=(15MB+1);sha256=('b'*64)})
 Assert-Fails {Assert-PlayerReleaseParts $oversized (15MB+1) ('c'*64)} '15 MiB'
 $unknown=@([pscustomobject]@{blob=('a'*40);bytes=1;sha256=('b'*64);url='https://example.invalid'})
 Assert-Fails {Assert-PlayerReleaseParts $unknown 1 ('c'*64)} 'PENDING'
 $wrongType=@([pscustomobject]@{blob=@('a'*40);bytes=1;sha256=('b'*64)})
 Assert-Fails {Assert-PlayerReleaseParts $wrongType 1 ('c'*64)} 'PENDING'

 # Run a sandbox copy of the real publisher with missing pins. A stub proves
 # no gh command is reached, without relying on network access or credentials.
 $sandbox=Join-Path $scratch 'publisher';$scripts=Join-Path $sandbox '.github/scripts'
 New-Item -ItemType Directory -Path $scripts|Out-Null
 foreach($name in @('publish-player-0.16.14.ps1','player-release-parts.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $scripts $name)}
 $pending=@{version='0.16.14';parts=@();sha256='PENDING';bytes=0;sourceBuild='PENDING';sourceWorkflow=0;sourceCommit='PENDING'}|ConvertTo-Json
 [IO.File]::WriteAllText((Join-Path $sandbox '.github/player-release-0.16.14.json'),$pending,[Text.UTF8Encoding]::new($false))
 $script:apiCalls=0
 function gh {$script:apiCalls++;throw 'Unexpected GitHub invocation.'}
 Assert-Fails {& (Join-Path $scripts 'publish-player-0.16.14.ps1')} 'PENDING'
 if($script:apiCalls -ne 0){throw 'Missing pins reached GitHub.'}
 Write-Output ('PASS: PowerShell '+$PSVersionTable.PSVersion.ToString()+': syntax, exact ordered ZIP reconstruction, tamper/order/oversize/unknown-field rejection, and missing-pin gate before every GitHub call.')
}finally {
 if(-not $scratch.StartsWith($githubRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Refusing cleanup outside the owned test directory.'}
 if(Test-Path -LiteralPath $scratch){Remove-Item -LiteralPath $scratch -Recurse -Force}
}
