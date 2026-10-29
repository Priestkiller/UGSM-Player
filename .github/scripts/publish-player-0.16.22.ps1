$ErrorActionPreference='Stop'
$repo='Priestkiller/UGSM-Player';$version='0.16.22';$tag='v'+$version
$project=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
. (Join-Path $PSScriptRoot 'player-release-parts-0.16.22.ps1')
$spec=Get-Content -LiteralPath (Join-Path $project '.github/player-release-0.16.22.json') -Raw|ConvertFrom-Json
# Missing pins must fail before any GitHub call or release mutation.
$specNames=@($spec.PSObject.Properties|ForEach-Object{$_.Name})
$requiredSpecNames=@('version','parts','sha256','bytes','sourceBuild','sourceWorkflow','sourceCommit')
if($specNames.Count -ne $requiredSpecNames.Count -or @($requiredSpecNames|Where-Object{$specNames -cnotcontains $_}).Count -ne 0 -or $spec.version -isnot [string] -or $spec.version -cne $version -or $spec.sha256 -isnot [string] -or $spec.sourceBuild -isnot [string] -or $spec.sourceCommit -isnot [string] -or ($spec.bytes -isnot [int] -and $spec.bytes -isnot [long])){throw 'PENDING: an exact approved public client release specification is required.'}
$approvedPackageBytes=59990188L
$approvedPackageSHA256='02e6bf0dca63c254eb8e279afbcd8aaa6935f02b1f4db8af79f63b45be20017d'
if($approvedPackageBytes -lt 1 -or $approvedPackageSHA256 -cnotmatch '\A[a-f0-9]{64}\z' -or $spec.bytes -ne $approvedPackageBytes -or $spec.sha256 -cne $approvedPackageSHA256){throw 'PENDING: the exact approved Player22 ZIP size and SHA256 must be pinned first.'}
Assert-PlayerReleaseParts $spec.parts ([long]$spec.bytes) ([string]$spec.sha256)
$approvedSourceBuild='f1d1f6a1fcf2e7980fbcb10983d9df6906daa2f4'
$approvedSourceWorkflow=40956022726L
if($approvedSourceWorkflow -lt 1 -or $spec.sourceBuild -cne $approvedSourceBuild -or $spec.sourceCommit -cne $approvedSourceBuild -or ($spec.sourceWorkflow -isnot [int] -and $spec.sourceWorkflow -isnot [long]) -or $spec.sourceWorkflow -ne $approvedSourceWorkflow){throw 'PENDING: the exact approved client CI source and successful workflow run must be pinned first.'}
if($env:GITHUB_REPOSITORY -cne $repo -or $env:GITHUB_REF -cne 'refs/heads/main' -or $env:GITHUB_SHA -cnotmatch '\A[a-f0-9]{40}\z'){throw 'Wrong public release repository, branch or commit.'}
if($env:GITHUB_EVENT_NAME -cne 'push' -or -not $env:GITHUB_EVENT_PATH){throw 'An exact public main push release event is required.'}
$eventFile=Get-Item -LiteralPath $env:GITHUB_EVENT_PATH
if($eventFile.PSIsContainer -or $eventFile.Length -lt 1 -or $eventFile.Length -gt 4MB){throw 'Invalid public release event.'}
$releaseEvent=Get-Content -LiteralPath $eventFile.FullName -Raw|ConvertFrom-Json
if($releaseEvent.ref -cne 'refs/heads/main' -or $releaseEvent.after -cne $env:GITHUB_SHA -or $releaseEvent.head_commit.id -cne $env:GITHUB_SHA -or $releaseEvent.head_commit.message -cne 'release: UGSM Player 0.16.22' -or $releaseEvent.repository.full_name -cne $repo -or $releaseEvent.repository.private -isnot [bool] -or $releaseEvent.repository.private){throw 'Wrong public repository, main commit or exact release message.'}
if([string]::IsNullOrWhiteSpace($env:GH_TOKEN) -or -not [string]::IsNullOrEmpty($env:GH_DEBUG)){throw 'A job-scoped token without verbose API tracing is required.'}
$env:GH_HOST='github.com'
$sha=[string]$spec.sha256;$size=[int64]$spec.bytes
$repoJSON=& gh api ('repos/'+$repo)
if($LASTEXITCODE){throw 'Cannot verify the public release repository.'}
$repository=$repoJSON|ConvertFrom-Json
if($repository.full_name -cne $repo -or $repository.private -isnot [bool] -or $repository.private -or $repository.default_branch -cne 'main'){throw 'Player downloads must use the intended public repository and main branch.'}
$root=Join-Path $env:RUNNER_TEMP ('ugsm-public-player-0.16.22-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root|Out-Null
$name='UGSM-Player-'+$version+'-Windows-x64.zip';$package=Join-Path $root $name
# Each <=15 MiB part is a pinned raw Git blob in this PUBLIC repository. Parts
# are data slices of the one approved CI ZIP, reconstructed in their given order.
Join-PlayerReleaseParts $spec.parts $size $sha $package {
 param($part)
 $raw=& gh api ('repos/'+$repo+'/git/blobs/'+[string]$part.blob)
 if($LASTEXITCODE){throw 'Cannot read a pinned public client ZIP part.'}
 $data=$raw|ConvertFrom-Json
 if($data.sha -cne [string]$part.blob -or $data.encoding -cne 'base64' -or $data.size -ne [long]$part.bytes -or $data.content -isnot [string]){throw 'Wrong pinned public ZIP part.'}
 $bytes=[Convert]::FromBase64String($data.content)
 $raw=$null;$data=$null
 return ,$bytes
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$allowed=@('UGSM.Player.exe','ugsm-player.exe','UGSM.Player.exe.config','THIRD-PARTY-NOTICES.txt','Anleitung.txt','sha256.json')
$zip=[IO.Compression.ZipFile]::OpenRead($package)
try {
 $seen=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase);$expanded=0L
 if($zip.Entries.Count -ne 6){throw 'Unexpected client ZIP member count.'}
 foreach($entry in $zip.Entries){
  $mode=($entry.ExternalAttributes -shr 16) -band 0xf000
  if($allowed -cnotcontains $entry.FullName -or -not $seen.Add($entry.FullName) -or $entry.Length -lt 1 -or $entry.Length -gt 100MB -or ($entry.ExternalAttributes -band 0x10) -ne 0 -or ($mode -ne 0 -and $mode -ne 0x8000)){throw 'Unexpected client ZIP member.'}
  $expanded+=$entry.Length
  if($expanded -gt 200MB){throw 'Expanded client ZIP exceeds the limit.'}
  if($entry.FullName -ceq 'sha256.json' -and $entry.Length -gt 16384){throw 'Internal client hash manifest is too large.'}
 }
}finally{$zip.Dispose()}
$payload=Join-Path $root 'payload'
[IO.Compression.ZipFile]::ExtractToDirectory($package,$payload)
$manifest=Get-Content -Raw -LiteralPath (Join-Path $payload 'sha256.json')|ConvertFrom-Json
$manifestNames=@($manifest.PSObject.Properties|ForEach-Object{$_.Name})
if($manifestNames.Count -ne 5){throw 'Unexpected internal client manifest.'}
foreach($file in $allowed|Where-Object{$_ -cne 'sha256.json'}){
 if($manifestNames -cnotcontains $file -or [string]$manifest.$file -cnotmatch '\A[a-f0-9]{64}\z' -or (Get-FileHash -LiteralPath (Join-Path $payload $file) -Algorithm SHA256).Hash.ToLowerInvariant() -cne [string]$manifest.$file){throw ('Internal client SHA256 mismatch: '+$file)}
}
$gui=Join-Path $payload 'UGSM.Player.exe'
if([Diagnostics.FileVersionInfo]::GetVersionInfo($gui).FileVersion -cne '0.16.22.0' -or [Reflection.AssemblyName]::GetAssemblyName($gui).Version.ToString(4) -cne '0.16.22.0'){throw 'Client executable version mismatch.'}
$sum=Join-Path $root 'SHA256SUMS-0.16.22.txt'
[IO.File]::WriteAllText($sum,($sha+'  '+$name+[Environment]::NewLine),[Text.UTF8Encoding]::new($false))
$proof=Join-Path $root 'client-package-verification-0.16.22.json'
[ordered]@{passed=$true;version=$version;bytes=$size;sha256=$sha;parts=$spec.parts;sourceBuild=$spec.sourceBuild;sourceWorkflow=$spec.sourceWorkflow;sourceCommit=$spec.sourceCommit;zipFiles=6;internalHashesVerified=$true;executableVersionVerified=$true;clientOrGameStarted=$false}|ConvertTo-Json -Depth 5|Set-Content -LiteralPath $proof -Encoding utf8
$files=@($package,$sum,$proof);$expected=@{}
foreach($file in $files){$item=Get-Item -LiteralPath $file;$expected[$item.Name]=@{size=$item.Length;digest='sha256:'+(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()}}
function ReadRelease {
 $json=& gh api ('repos/'+$repo+'/releases?per_page=100')
 if($LASTEXITCODE){throw 'Cannot read public releases.'}
 $found=@(($json|ConvertFrom-Json)|Where-Object{$_.tag_name -ceq $tag})
 if($found.Count -gt 1){throw 'Ambiguous release.'}
 if($found.Count -eq 1){return $found[0]};return $null
}
$release=ReadRelease
if($release -and -not $release.draft){
 if($release.prerelease -or $release.target_commitish -cne $env:GITHUB_SHA -or @($release.assets).Count -ne $files.Count){throw 'Existing stable release differs; nothing overwritten.'}
 foreach($file in $files){
  $filename=[IO.Path]::GetFileName($file);$asset=@($release.assets|Where-Object{$_.name -ceq $filename})
  if($asset.Count -ne 1 -or $asset[0].state -ne 'uploaded' -or $asset[0].size -ne $expected[$filename].size -or $asset[0].digest -cne $expected[$filename].digest){throw 'Existing stable release asset differs; nothing overwritten.'}
 }
 Write-Output 'The exact stable client package and all verification assets are already published.';exit 0
}
if($release -and $release.target_commitish -cne $env:GITHUB_SHA){throw 'Draft belongs to another public source commit.'}
if(-not $release){
 & gh release create $tag --repo $repo --target $env:GITHUB_SHA --draft --title 'UGSM Spielerclient 0.16.22' --notes-file (Join-Path $project '.github/player-release-notes-0.16.22.md')
 if($LASTEXITCODE){throw 'Cannot create release draft.'}
}
# The release list can briefly lag behind successful draft creation. Retry only
# absent metadata; a visible draft must still match the exact approved head.
for($draftAttempt=0;$draftAttempt -lt 6;$draftAttempt++){
 $release=ReadRelease
 if($release){
  if(-not $release.draft -or $release.prerelease -or $release.target_commitish -cne $env:GITHUB_SHA){throw 'Approved release draft could not be confirmed.'}
  break
 }
 if($draftAttempt -lt 5){Start-Sleep -Seconds 5}
}
if(-not $release){throw 'Approved release draft could not be confirmed.'}
foreach($file in $files){
 $item=Get-Item -LiteralPath $file;$present=@($release.assets|Where-Object{$_.name -ceq $item.Name})
 if($present.Count -gt 0){
  if($present.Count -ne 1 -or $present[0].state -ne 'uploaded' -or $present[0].size -ne $expected[$item.Name].size -or $present[0].digest -cne $expected[$item.Name].digest){throw 'Existing draft asset differs; nothing overwritten.'}
 }else{
  & gh release upload $tag $file --repo $repo
  if($LASTEXITCODE){throw 'Upload failed; release remains a draft.'}
 }
}
$verified=$false
for($attempt=0;$attempt -lt 6;$attempt++){
 $release=ReadRelease;$valid=$true
 if(-not $release -or -not $release.draft -or $release.prerelease -or $release.target_commitish -cne $env:GITHUB_SHA){throw 'Release no longer matches the approved draft.'}
 if($release.assets.Count -ne $files.Count){throw 'Unexpected draft asset; release remains a draft.'}
 foreach($file in $files){
  $filename=[IO.Path]::GetFileName($file);$asset=@($release.assets|Where-Object{$_.name -ceq $filename})
  if($asset.Count -ne 1 -or $asset[0].state -ne 'uploaded' -or $asset[0].size -ne $expected[$filename].size -or $asset[0].digest -cne $expected[$filename].digest){$valid=$false;break}
 }
 if($valid){$verified=$true;break};Start-Sleep -Seconds 5
}
if(-not $verified){throw 'Uploaded assets could not be verified; release remains a draft.'}
$request=Join-Path $root 'publish.json'
[IO.File]::WriteAllText($request,(@{draft=$false;prerelease=$false;make_latest='true'}|ConvertTo-Json),[Text.UTF8Encoding]::new($false))
$json=& gh api --method PATCH ('repos/'+$repo+'/releases/'+$release.id) --input $request
if($LASTEXITCODE -or ($json|ConvertFrom-Json).draft -or ($json|ConvertFrom-Json).prerelease){throw 'Cannot publish verified release.'}
Write-Output ('Published '+($json|ConvertFrom-Json).html_url)
