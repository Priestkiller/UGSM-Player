param([Parameter(Mandatory=$true)][string]$WorkDirectory)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-release-parts-0.16.26.ps1')
$workParent=[IO.Path]::GetFullPath($WorkDirectory)
New-Item -ItemType Directory -Path $workParent -Force|Out-Null
$scratch=Join-Path $workParent ('player26-preflight-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $scratch|Out-Null
$checks=[Collections.Generic.List[string]]::new()
function Assert-Player26Failure([scriptblock]$Action,[string]$Message){
 $failed=$false
 try {& $Action}catch{$failed=$true;if($Message -and $_.Exception.Message -notlike ('*'+$Message+'*')){throw}}
 if(-not $failed){throw 'Expected Player26 rejection did not occur.'}
}
foreach($file in @('publish-player-0.16.26.ps1','player-release-parts-0.16.26.ps1','test-player-release-0.16.26.ps1')){
 $tokens=$null;$parseErrors=$null
 $null=[Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot $file),[ref]$tokens,[ref]$parseErrors)
 if($parseErrors.Count){throw ($parseErrors|Out-String)}
}
$checks.Add('Version-specific publisher, parts helper and preflight parse')
Add-Type -AssemblyName System.IO.Compression
$memory=[IO.MemoryStream]::new()
$zip=[IO.Compression.ZipArchive]::new($memory,[IO.Compression.ZipArchiveMode]::Create,$true)
try{
 $entry=$zip.CreateEntry('fixture.txt',[IO.Compression.CompressionLevel]::NoCompression)
 $entry.LastWriteTime=[DateTimeOffset]::new(2000,1,1,0,0,0,[TimeSpan]::Zero)
 $stream=$entry.Open()
 try{$bytes=[Text.Encoding]::UTF8.GetBytes('Synthetic ordered Player26 release verification bytes; no executable, account or private artifact.');$stream.Write($bytes,0,$bytes.Length)}finally{$stream.Dispose()}
}finally{$zip.Dispose()}
$expected=$memory.ToArray();$memory.Dispose();$sha=Get-PlayerReleaseSHA256 $expected
$chunks=@{};$parts=@();$offset=0
foreach($length in @(31,47,($expected.Length-78))){
 $chunk=[byte[]]::new($length);[Array]::Copy($expected,$offset,$chunk,0,$length)
 $blob=([string]($parts.Count+1))*40;$chunks[$blob]=$chunk
 $parts+=,[pscustomobject]@{blob=$blob;bytes=$length;sha256=(Get-PlayerReleaseSHA256 $chunk)}
 $offset+=$length
}
$reader={param($part);return ,([byte[]]$chunks[[string]$part.blob])}
$joined=Join-Path $scratch 'exact.zip'
Join-PlayerReleaseParts $parts $expected.LongLength $sha $joined $reader
if([Convert]::ToBase64String([IO.File]::ReadAllBytes($joined)) -cne [Convert]::ToBase64String($expected)){throw 'Ordered reconstruction changed synthetic bytes.'}
$checks.Add('Ordered public-part reconstruction preserves exact ZIP bytes')
$reversed=@($parts[2],$parts[1],$parts[0])
Assert-Player26Failure {Join-PlayerReleaseParts $reversed $expected.LongLength $sha (Join-Path $scratch 'reversed.zip') $reader} 'SHA256 mismatch'
$corrupt={param($part);$bytes=([byte[]]$chunks[[string]$part.blob]).Clone();$bytes[0]=$bytes[0] -bxor 1;return ,$bytes}
Assert-Player26Failure {Join-PlayerReleaseParts $parts $expected.LongLength $sha (Join-Path $scratch 'corrupt.zip') $corrupt} 'part size or SHA256 mismatch'
Assert-Player26Failure {Join-PlayerReleaseParts $parts $expected.LongLength $sha $joined $reader} ''
Assert-Player26Failure {Assert-PlayerReleaseParts @() 0 'PENDING'} 'PENDING'
Assert-Player26Failure {Assert-PlayerReleaseParts @([pscustomobject]@{blob=('a'*40);bytes=(15MB+1);sha256=('b'*64)}) (15MB+1) ('c'*64)} '15 MiB'
Assert-Player26Failure {Assert-PlayerReleaseParts @([pscustomobject]@{blob=('a'*40);bytes=1;sha256=('b'*64);url='https://example.invalid'}) 1 ('c'*64)} 'PENDING'
$checks.Add('Reordering, corruption, overwrite, missing pins, oversized parts and unknown fields reject')
$sandbox=Join-Path $scratch 'publisher';$sandboxScripts=Join-Path $sandbox '.github/scripts'
New-Item -ItemType Directory -Path $sandboxScripts -Force|Out-Null
foreach($file in @('publish-player-0.16.26.ps1','player-release-parts-0.16.26.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination (Join-Path $sandboxScripts $file)}
$pending=[ordered]@{version='0.16.26';parts=@();sha256='PENDING';bytes=0;sourceBuild='PENDING';sourceWorkflow=0;sourceCommit='PENDING'}
[IO.File]::WriteAllText((Join-Path $sandbox '.github/player-release-0.16.26.json'),($pending|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
$script:player26ApiCalls=0
function gh{$script:player26ApiCalls++;throw 'Unexpected GitHub invocation during local preflight.'}
Assert-Player26Failure {& (Join-Path $sandboxScripts 'publish-player-0.16.26.ps1')} 'PENDING'
if($script:player26ApiCalls -ne 0){throw 'Pending approval pins reached GitHub.'}
$checks.Add('Pending package/source pins fail before every GitHub command')
$report=[ordered]@{passed=$true;version='0.16.26';checks=@($checks);count=$checks.Count;networkUsed=$false;githubMutated=$false;privateSourceChanged=$false;installerOrGameStarted=$false;checkedAt=[DateTime]::UtcNow.ToString('o');workDirectory=$scratch}
[IO.File]::WriteAllText((Join-Path $workParent 'player-release-preflight-0.16.26.json'),($report|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
$report|ConvertTo-Json -Depth 5
