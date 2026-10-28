$ErrorActionPreference='Stop'
function Assert-Player18ArtifactSpec($Spec) {
 $required=@('version','artifact','sha256','bytes','sourceBuild','sourceWorkflow','sourceCommit')
 $names=@($Spec.PSObject.Properties|ForEach-Object{$_.Name})
 if($Spec -isnot [pscustomobject] -or $names.Count -ne $required.Count -or @($required|Where-Object{$names -cnotcontains $_}).Count){throw 'Exact approved Player18 artifact specification required.'}
 if($Spec.version -isnot [string] -or $Spec.version -cne '0.16.18' -or $Spec.sha256 -isnot [string] -or $Spec.sha256 -cne '78bd298ae34a0c424d58c676745fdc78696e9cec5f4ba48e91406404dc5480c3' -or ($Spec.bytes -isnot [int] -and $Spec.bytes -isnot [long]) -or $Spec.bytes -ne 61447931L){throw 'Approved Player18 ZIP hash, size or version differs.'}
 $build='d6695e6f33e840ddb75c3acc284a759cbc232dba'
 if($Spec.sourceBuild -isnot [string] -or $Spec.sourceBuild -cne $build -or $Spec.sourceCommit -isnot [string] -or $Spec.sourceCommit -cne $build -or ($Spec.sourceWorkflow -isnot [int] -and $Spec.sourceWorkflow -isnot [long]) -or $Spec.sourceWorkflow -ne 40742100776L){throw 'Approved private source commit or successful workflow differs.'}
 $artifact=$Spec.artifact;$artifactNames=@($artifact.PSObject.Properties|ForEach-Object{$_.Name})
 if($artifact -isnot [pscustomobject] -or $artifactNames.Count -ne 4 -or @(@('id','bytes','sha256','url')|Where-Object{$artifactNames -cnotcontains $_}).Count -or ($artifact.id -isnot [int] -and $artifact.id -isnot [long]) -or $artifact.id -ne 12840666559L -or ($artifact.bytes -isnot [int] -and $artifact.bytes -isnot [long]) -or $artifact.bytes -ne 61460337L -or $artifact.sha256 -isnot [string] -or $artifact.sha256 -cne '3984bc9be77515c9993b25b2145e54fdaaeaa0fb62012b645882564435647856'){throw 'Approved CI artifact identity, size or SHA256 differs.'}
 $url=$artifact.url;$uri=$null
 if($url -isnot [string] -or $url.Length -gt 8192 -or $url -match '[\r\n\x00]' -or -not [Uri]::TryCreate($url,[UriKind]::Absolute,[ref]$uri) -or $uri.Scheme -cne 'https' -or $uri.DnsSafeHost -cne 'sdmntprdenmarkeast.oaiusercontent.com' -or $uri.Port -ne 443 -or $uri.UserInfo -or $uri.Fragment -or $uri.AbsolutePath -cnotmatch '\A/files/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/raw\z' -or $url -cnotmatch '\Ahttps://sdmntprdenmarkeast\.oaiusercontent\.com/files/[0-9a-fA-F-]{36}/raw\?' -or $uri.Query.Length -lt 2){throw 'Only the approved HTTPS raw artifact URL host and path are allowed.'}
}
function Receive-Player18CIArtifact($Spec,[string]$OutputFile) {
 Assert-Player18ArtifactSpec $Spec
 Add-Type -AssemblyName System.Net.Http
 $handler=[Net.Http.HttpClientHandler]::new();$handler.AllowAutoRedirect=$false;$handler.UseCookies=$false;$handler.UseDefaultCredentials=$false
 $client=[Net.Http.HttpClient]::new($handler);$client.Timeout=[TimeSpan]::FromMinutes(3)
 $response=$null;$input=$null;$output=$null
 try {
  # Fresh client: no GH token, credentials, cookies or authorization header.
  $response=$client.GetAsync([Uri]$Spec.artifact.url,[Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
  if([int]$response.StatusCode -ne 200){throw 'Approved CI artifact download failed or expired; no redirect is followed.'}
  $length=$response.Content.Headers.ContentLength
  if($null -ne $length -and $length -ne [long]$Spec.artifact.bytes){throw 'CI artifact HTTP length differs.'}
  $input=$response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
  $output=[IO.File]::Open($OutputFile,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
  $buffer=New-Object byte[] 524288;$written=0L
  while(($read=$input.Read($buffer,0,$buffer.Length)) -gt 0){$written+=$read;if($written -gt [long]$Spec.artifact.bytes){throw 'CI artifact download exceeds approved size.'};$output.Write($buffer,0,$read)}
  if($written -ne [long]$Spec.artifact.bytes){throw 'CI artifact download is incomplete.'}
 }finally{if($output){$output.Dispose()};if($input){$input.Dispose()};if($response){$response.Dispose()};$client.Dispose();$handler.Dispose()}
 if((Get-FileHash -LiteralPath $OutputFile -Algorithm SHA256).Hash.ToLowerInvariant() -cne [string]$Spec.artifact.sha256){throw 'Downloaded CI artifact SHA256 differs.'}
}
function Copy-Player18CIArtifactPackage($Spec,[string]$WrapperFile,[string]$OutputFile) {
 Assert-Player18ArtifactSpec $Spec
 $wrapper=Get-Item -LiteralPath $WrapperFile
 if($wrapper.PSIsContainer -or $wrapper.Length -ne [long]$Spec.artifact.bytes -or (Get-FileHash -LiteralPath $WrapperFile -Algorithm SHA256).Hash.ToLowerInvariant() -cne [string]$Spec.artifact.sha256){throw 'Local CI artifact size or SHA256 differs.'}
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $zip=[IO.Compression.ZipFile]::OpenRead($WrapperFile)
 try {
  if($zip.Entries.Count -ne 2){throw 'CI artifact must contain only the approved client ZIP and package proof.'}
  $seen=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal);$clientEntry=$null
  foreach($entry in $zip.Entries){
   $mode=($entry.ExternalAttributes -shr 16) -band 0xf000
   if(@('UGSM-Player-0.16.18-Windows-x64.zip','package-verification.json') -cnotcontains $entry.FullName -or -not $seen.Add($entry.FullName) -or ($entry.ExternalAttributes -band 0x10) -ne 0 -or ($mode -ne 0 -and $mode -ne 0x8000)){throw 'Unexpected CI artifact member or file type.'}
   if($entry.FullName -ceq 'UGSM-Player-0.16.18-Windows-x64.zip'){if($entry.Length -ne [long]$Spec.bytes){throw 'Wrapped client ZIP size differs.'};$clientEntry=$entry}
   elseif($entry.Length -lt 1 -or $entry.Length -gt 16384){throw 'CI package proof size differs.'}
  }
  if(-not $clientEntry){throw 'Approved client ZIP is missing from CI artifact.'}
  $input=$clientEntry.Open();$output=$null
  try{
   $output=[IO.File]::Open($OutputFile,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
   $buffer=New-Object byte[] 524288;$written=0L
   while(($read=$input.Read($buffer,0,$buffer.Length)) -gt 0){$written+=$read;if($written -gt [long]$Spec.bytes){throw 'Wrapped client ZIP exceeds approved size.'};$output.Write($buffer,0,$read)}
   if($written -ne [long]$Spec.bytes){throw 'Wrapped client ZIP is incomplete.'}
  }finally{if($output){$output.Dispose()};$input.Dispose()}
 }finally{$zip.Dispose()}
 if((Get-Item -LiteralPath $OutputFile).Length -ne [long]$Spec.bytes -or (Get-FileHash -LiteralPath $OutputFile -Algorithm SHA256).Hash.ToLowerInvariant() -cne [string]$Spec.sha256){throw 'Approved client ZIP size or SHA256 differs.'}
}
$repo='Priestkiller/UGSM-Player';$version='0.16.18';$tag='v'+$version
$project=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$spec=Get-Content -LiteralPath (Join-Path $project '.github/player-release-0.16.18.json') -Raw|ConvertFrom-Json
# Missing pins must fail before any GitHub call or release mutation.
Assert-Player18ArtifactSpec $spec
if($env:GITHUB_REPOSITORY -cne $repo -or $env:GITHUB_REF -cne 'refs/heads/main' -or $env:GITHUB_SHA -cnotmatch '\A[a-f0-9]{40}\z'){throw 'Wrong public release repository, branch or commit.'}
if($env:GITHUB_EVENT_NAME -cne 'push' -or -not $env:GITHUB_EVENT_PATH){throw 'An exact public main push release event is required.'}
$eventFile=Get-Item -LiteralPath $env:GITHUB_EVENT_PATH
if($eventFile.PSIsContainer -or $eventFile.Length -lt 1 -or $eventFile.Length -gt 4MB){throw 'Invalid public release event.'}
$releaseEvent=Get-Content -LiteralPath $eventFile.FullName -Raw|ConvertFrom-Json
if($releaseEvent.ref -cne 'refs/heads/main' -or $releaseEvent.after -cne $env:GITHUB_SHA -or $releaseEvent.head_commit.id -cne $env:GITHUB_SHA -or $releaseEvent.head_commit.message -cne 'release: UGSM Player 0.16.18' -or $releaseEvent.repository.full_name -cne $repo -or $releaseEvent.repository.private -isnot [bool] -or $releaseEvent.repository.private){throw 'Wrong public repository, main commit or exact release message.'}
if([string]::IsNullOrWhiteSpace($env:GH_TOKEN) -or -not [string]::IsNullOrEmpty($env:GH_DEBUG)){throw 'A job-scoped token without verbose API tracing is required.'}
$env:GH_HOST='github.com'
$sha=[string]$spec.sha256;$size=[int64]$spec.bytes
$repoJSON=& gh api ('repos/'+$repo)
if($LASTEXITCODE){throw 'Cannot verify the public release repository.'}
$repository=$repoJSON|ConvertFrom-Json
if($repository.full_name -cne $repo -or $repository.private -isnot [bool] -or $repository.private -or $repository.default_branch -cne 'main'){throw 'Player downloads must use the intended public repository and main branch.'}
$root=Join-Path $env:RUNNER_TEMP ('ugsm-public-player-0.16.18-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root|Out-Null
$name='UGSM-Player-'+$version+'-Windows-x64.zip';$package=Join-Path $root $name
# One-time read-only CI artifact URL; exact wrapper and inner ZIP pins are fixed.
$wrapperFile=Join-Path $root 'approved-ci-wrapper.zip'
Receive-Player18CIArtifact $spec $wrapperFile
Copy-Player18CIArtifactPackage $spec $wrapperFile $package
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
if([Diagnostics.FileVersionInfo]::GetVersionInfo($gui).FileVersion -cne '0.16.18.0' -or [Reflection.AssemblyName]::GetAssemblyName($gui).Version.ToString(4) -cne '0.16.18.0'){throw 'Client executable version mismatch.'}
$sum=Join-Path $root 'SHA256SUMS-0.16.18.txt'
[IO.File]::WriteAllText($sum,($sha+'  '+$name+[Environment]::NewLine),[Text.UTF8Encoding]::new($false))
$proof=Join-Path $root 'client-package-verification-0.16.18.json'
[ordered]@{passed=$true;version=$version;bytes=$size;sha256=$sha;artifact=[ordered]@{id=$spec.artifact.id;bytes=$spec.artifact.bytes;sha256=$spec.artifact.sha256};sourceBuild=$spec.sourceBuild;sourceWorkflow=$spec.sourceWorkflow;sourceCommit=$spec.sourceCommit;zipFiles=6;internalHashesVerified=$true;executableVersionVerified=$true;clientOrGameStarted=$false}|ConvertTo-Json -Depth 5|Set-Content -LiteralPath $proof -Encoding utf8
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
 & gh release create $tag --repo $repo --target $env:GITHUB_SHA --draft --title 'UGSM Spielerclient 0.16.18' --notes-file (Join-Path $project '.github/player-release-notes-0.16.18.md')
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
