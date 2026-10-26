$ErrorActionPreference='Stop'
$repo='Priestkiller/UGSM-Player';$version='0.16.13';$tag='v'+$version
$project=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$spec=Get-Content -LiteralPath (Join-Path $project '.github/player-release-0.16.13.json') -Raw|ConvertFrom-Json
# Missing pins must fail before any GitHub call or release mutation.
if($spec.version -cne $version -or $spec.blob -cnotmatch '\A[a-f0-9]{40}\z' -or $spec.sha256 -cnotmatch '\A[a-f0-9]{64}\z' -or ($spec.bytes -isnot [int] -and $spec.bytes -isnot [long]) -or $spec.bytes -lt 1 -or $spec.bytes -gt 50MB){throw 'PENDING: the approved public raw ZIP blob, exact SHA256 and positive size must be pinned first.'}
if($spec.sourceBuild -cne '42a8ba053e7cadfe51e825ac5e1908b1d5dbeacd' -or $spec.sourceWorkflow -ne 40377486040){throw 'Wrong approved client CI source.'}
if($env:GITHUB_REPOSITORY -cne $repo -or $env:GITHUB_REF -cne 'refs/heads/main' -or $env:GITHUB_SHA -cnotmatch '\A[a-f0-9]{40}\z'){throw 'Wrong public release repository, branch or commit.'}
if([string]::IsNullOrWhiteSpace($env:GH_TOKEN) -or -not [string]::IsNullOrEmpty($env:GH_DEBUG)){throw 'A job-scoped token without verbose API tracing is required.'}
$sha=[string]$spec.sha256;$size=[int64]$spec.bytes;$blob=[string]$spec.blob
$repoJSON=& gh api ('repos/'+$repo)
if($LASTEXITCODE){throw 'Cannot verify the public release repository.'}
$repository=$repoJSON|ConvertFrom-Json
if($repository.full_name -cne $repo -or $repository.private -isnot [bool] -or $repository.private){throw 'Player downloads must use the intended public repository.'}
$root=Join-Path $env:RUNNER_TEMP ('ugsm-public-player-0.16.13-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root|Out-Null
$name='UGSM-Player-'+$version+'-Windows-x64.zip';$package=Join-Path $root $name
# This is the normal API representation of a pinned PUBLIC raw ZIP Git blob.
# No private intermediate blob, repository, game archive or key is accessed.
$raw=& gh api ('repos/'+$repo+'/git/blobs/'+$blob)
if($LASTEXITCODE){throw 'Cannot read the pinned public client ZIP.'}
$data=$raw|ConvertFrom-Json
if($data.sha -cne $blob -or $data.encoding -cne 'base64' -or $data.size -ne $size){throw 'Wrong pinned public ZIP blob.'}
[IO.File]::WriteAllBytes($package,[Convert]::FromBase64String($data.content))
$raw=$null;$data=$null
if((Get-Item -LiteralPath $package).Length -ne $size -or (Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash.ToLowerInvariant() -cne $sha){throw 'Client ZIP size or SHA256 mismatch.'}
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
if([Diagnostics.FileVersionInfo]::GetVersionInfo($gui).FileVersion -cne '0.16.13.0' -or [Reflection.AssemblyName]::GetAssemblyName($gui).Version.ToString(4) -cne '0.16.13.0'){throw 'Client executable version mismatch.'}
$sum=Join-Path $root 'SHA256SUMS-0.16.13.txt'
[IO.File]::WriteAllText($sum,($sha+'  '+$name+[Environment]::NewLine),[Text.UTF8Encoding]::new($false))
$proof=Join-Path $root 'client-package-verification-0.16.13.json'
@{passed=$true;version=$version;bytes=$size;sha256=$sha;sourceBuild=$spec.sourceBuild;sourceWorkflow=$spec.sourceWorkflow;zipFiles=6;internalHashesVerified=$true;executableVersionVerified=$true;clientOrGameStarted=$false}|ConvertTo-Json|Set-Content -LiteralPath $proof -Encoding utf8
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
 $asset=@($release.assets|Where-Object{$_.name -ceq $name})
 if($release.prerelease -or $asset.Count -ne 1 -or $asset[0].state -ne 'uploaded' -or $asset[0].size -ne $size -or $asset[0].digest -cne ('sha256:'+$sha)){throw 'Existing stable release differs; nothing overwritten.'}
 Write-Output 'The exact stable client ZIP is already published.';exit 0
}
if($release -and $release.target_commitish -cne $env:GITHUB_SHA){throw 'Draft belongs to another public source commit.'}
if(-not $release){
 & gh release create $tag --repo $repo --target $env:GITHUB_SHA --draft --title 'UGSM Spielerclient 0.16.13' --notes-file (Join-Path $project '.github/player-release-notes-0.16.13.md')
 if($LASTEXITCODE){throw 'Cannot create release draft.'}
}
$release=ReadRelease
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
