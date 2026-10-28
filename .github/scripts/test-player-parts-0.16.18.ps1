param([Parameter(Mandatory=$true)][string]$PackageFile,[Parameter(Mandatory=$true)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'player-release-parts-0.16.18.ps1')
$source=[IO.Path]::GetFullPath($PackageFile)
$expectedSize=61447931L;$expectedSHA='78bd298ae34a0c424d58c676745fdc78696e9cec5f4ba48e91406404dc5480c3'
if((Get-Item -LiteralPath $source).Length -ne $expectedSize -or (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -cne $expectedSHA){throw 'Exact approved local Player18 ZIP required.'}
$output=[IO.Path]::GetFullPath($OutputDirectory);New-Item -ItemType Directory -Path $output -Force|Out-Null
$scratch=Join-Path $output ('parts-'+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $scratch|Out-Null
$checks=[Collections.Generic.List[string]]::new()
function Assert-Fails([scriptblock]$Action,[string]$Message){
 $failed=$false;try{& $Action}catch{$failed=$true;if($Message -and $_.Exception.Message -notlike ('*'+$Message+'*')){throw}}
 if(-not $failed){throw 'Expected rejection did not occur.'}
}
foreach($file in @('publish-player-0.16.18.ps1','player-release-parts-0.16.18.ps1','test-player-parts-0.16.18.ps1')){
 $tokens=$null;$errors=$null;$null=[Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot $file),[ref]$tokens,[ref]$errors)
 if($errors.Count){throw 'New18 PowerShell parse error.'}
}
$checks.Add('New18 publisher, helper and harness parse on current PowerShell')
$stream=[IO.File]::OpenRead($source);$parts=@();$offsets=@{}
try{
 $offset=0L
 while($offset -lt $expectedSize){
  $length=[int][Math]::Min(1MB,$expectedSize-$offset);$bytes=New-Object byte[] $length
  if($stream.Read($bytes,0,$length) -ne $length){throw 'Local ZIP slice incomplete.'}
  $sha=Get-PlayerReleaseSHA256 $bytes;$blob=$sha.Substring(0,40)
  $offsets[$blob]=$offset;$parts+=,[pscustomobject]@{blob=$blob;bytes=$length;sha256=$sha};$offset+=$length
 }
 if($parts.Count -ne 59){throw 'Expected59 one-MiB slices.'}
 $reader={param($part);$stream.Position=[long]$offsets[[string]$part.blob];$bytes=New-Object byte[] ([int]$part.bytes);if($stream.Read($bytes,0,$bytes.Length) -ne $bytes.Length){throw 'Short local read.'};return ,$bytes}
 $joined=Join-Path $scratch 'exact.zip';Join-PlayerReleaseParts $parts $expectedSize $expectedSHA $joined $reader
 $checks.Add('All59 ordered one-MiB slices reconstruct the exact approved61447931-byte ZIP and whole SHA256')
 $reversed=@($parts);[Array]::Reverse($reversed)
 Assert-Fails {Join-PlayerReleaseParts $reversed $expectedSize $expectedSHA (Join-Path $scratch 'reversed.zip') $reader} 'SHA256 mismatch'
 $checks.Add('Reversed59-slice order rejected by whole-ZIP hash')
 $corrupt={param($part);$bytes=& $reader $part;$bytes[0]=$bytes[0] -bxor 1;return ,$bytes}
 Assert-Fails {Join-PlayerReleaseParts $parts $expectedSize $expectedSHA (Join-Path $scratch 'corrupt.zip') $corrupt} 'part size or SHA256 mismatch'
 $checks.Add('Corrupt slice rejected before package use')
 $short={param($part);$bytes=& $reader $part;$shortBytes=New-Object byte[] ($bytes.Length-1);[Array]::Copy($bytes,$shortBytes,$shortBytes.Length);return ,$shortBytes}
 Assert-Fails {Join-PlayerReleaseParts $parts $expectedSize $expectedSHA (Join-Path $scratch 'short.zip') $short} 'part size or SHA256 mismatch'
 $checks.Add('Short slice rejected before package use')
 Assert-Fails {Assert-PlayerReleaseParts (@($parts)+@($parts[0])*6) $expectedSize $expectedSHA} 'PENDING'
 Assert-Fails {Assert-PlayerReleaseParts @([pscustomobject]@{blob=('a'*40);bytes=(15MB+1);sha256=('b'*64)}) (15MB+1) ('c'*64)} '15 MiB'
 Assert-Fails {Assert-PlayerReleaseParts $parts (128MB+1) $expectedSHA} 'PENDING'
 $checks.Add('More than64 parts, individual size over15MiB, and total over128MiB rejected')
 $unknown=[pscustomobject]@{blob=('a'*40);bytes=1;sha256=('b'*64);extra=1}
 Assert-Fails {Assert-PlayerReleaseParts @($unknown) 1 ('c'*64)} 'PENDING'
 $checks.Add('Unknown part metadata rejected')
 $scripts=Join-Path $scratch 'sandbox/.github/scripts';New-Item -ItemType Directory -Path $scripts -Force|Out-Null
 foreach($file in @('publish-player-0.16.18.ps1','player-release-parts-0.16.18.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination (Join-Path $scripts $file)}
 $spec=[pscustomobject]@{version='0.16.18';parts=$parts;sha256=$expectedSHA;bytes=$expectedSize;sourceBuild='d6695e6f33e840ddb75c3acc284a759cbc232dba';sourceWorkflow=40742100776L;sourceCommit='d6695e6f33e840ddb75c3acc284a759cbc232dba'}
 $script:apiCalls=0;function gh{$script:apiCalls++;throw 'Unexpected GitHub call.'}
 foreach($badCase in @('zip-hash','zip-size','source-build','source-run','schema')){
  $bad=$spec|ConvertTo-Json -Depth 5|ConvertFrom-Json
  switch($badCase){'zip-hash'{$bad.sha256=('0'*64)} 'zip-size'{$bad.bytes--} 'source-build'{$bad.sourceBuild=('0'*40)} 'source-run'{$bad.sourceWorkflow--} 'schema'{$bad|Add-Member artifact 1}}
  $specFile=Join-Path $scratch 'sandbox/.github/player-release-0.16.18.json'
  [IO.File]::WriteAllText($specFile,($bad|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
  $message=if($badCase -like 'zip-*'){'exact approved Player18'}else{'PENDING'}
  Assert-Fails {& (Join-Path $scripts 'publish-player-0.16.18.ps1')} $message
  if($script:apiCalls -ne 0){throw 'Invalid pins reached GitHub.'}
  $checks.Add(('Rejected before every GitHub call: '+$badCase))
 }
}finally{
 $stream.Dispose()
 foreach($file in @('exact.zip','reversed.zip','corrupt.zip','short.zip')){ $path=Join-Path $scratch $file;if(Test-Path -LiteralPath $path){Remove-Item -LiteralPath $path -Force}}
}
$report=[ordered]@{passed=$true;parts=59;checks=@($checks);count=$checks.Count;networkUsed=$false;githubMutated=$false;gameStarted=$false;checkedAt=[DateTime]::UtcNow.ToString('o')}
[IO.File]::WriteAllText((Join-Path $output 'parts-verification.json'),($report|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
$report|ConvertTo-Json -Depth 5
