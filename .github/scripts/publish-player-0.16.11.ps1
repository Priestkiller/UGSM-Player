$ErrorActionPreference='Stop'
$repo='Priestkiller/UGSM-Player';$version='0.16.11';$tag='v'+$version
$sha='1b24cdaf40b7d7404fd142456e6ff7eeec9ebf7e52ab707d7dc448be8111a95f'
$size=18192370;$blob='33e23441e89c826074e7a81266d52c0ec7bc4e7f'
if($env:GITHUB_REPOSITORY-ne$repo-or$env:GITHUB_REF-ne'refs/heads/main'){throw 'Wrong release repository or branch'}
$root=Join-Path $env:RUNNER_TEMP 'ugsm-public-player-0.16.11'
New-Item -ItemType Directory -Path $root -Force|Out-Null
$name='UGSM-Player-'+$version+'-Windows-x64.zip';$package=Join-Path $root $name
$raw=& gh api ('repos/'+$repo+'/git/blobs/'+$blob)
if($LASTEXITCODE){throw 'Cannot read the pinned client package'}
$data=$raw|ConvertFrom-Json
if($data.sha-ne$blob-or$data.encoding-ne'base64'-or$data.size-ne$size){throw 'Wrong pinned client blob'}
[IO.File]::WriteAllBytes($package,[Convert]::FromBase64String($data.content))
$raw=$null;$data=$null
if((Get-Item -LiteralPath $package).Length-ne$size-or(Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash.ToLowerInvariant()-ne$sha){throw 'Client package hash or size mismatch'}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$allowed=@('UGSM.Player.exe','ugsm-player.exe','UGSM.Player.exe.config','THIRD-PARTY-NOTICES.txt','Anleitung.txt','sha256.json')
$zip=[IO.Compression.ZipFile]::OpenRead($package)
try {
 if($zip.Entries.Count-ne6-or@($zip.Entries|Select-Object -ExpandProperty FullName -Unique).Count-ne6){throw 'Unexpected client ZIP layout'}
 foreach($entry in $zip.Entries){if($allowed-cnotcontains$entry.FullName-or$entry.Length-lt1-or$entry.Length-gt100MB){throw 'Unexpected client ZIP member'}}
}finally{$zip.Dispose()}
$payload=Join-Path $root 'payload'
[IO.Compression.ZipFile]::ExtractToDirectory($package,$payload)
$manifest=Get-Content -Raw -LiteralPath (Join-Path $payload 'sha256.json')|ConvertFrom-Json
if(@($manifest.PSObject.Properties).Count-ne5){throw 'Unexpected internal client manifest'}
foreach($file in $allowed|Where-Object{$_-ne'sha256.json'}){
 if((Get-FileHash -LiteralPath (Join-Path $payload $file) -Algorithm SHA256).Hash.ToLowerInvariant()-cne$manifest.$file){throw 'Internal client file hash mismatch'}
}
if([Diagnostics.FileVersionInfo]::GetVersionInfo((Join-Path $payload 'UGSM.Player.exe')).FileVersion-cne'0.16.11.0'){throw 'Client executable version mismatch'}
$sum=Join-Path $root 'SHA256SUMS-0.16.11.txt'
[IO.File]::WriteAllText($sum,($sha+'  '+$name+[Environment]::NewLine),[Text.UTF8Encoding]::new($false))
$proof=Join-Path $root 'client-package-verification-0.16.11.json'
@{passed=$true;version=$version;bytes=$size;sha256=$sha;sourceBuild='f31e7b2ac245799ad7a7ff29d762bd09e58a239c';sourceWorkflow=40321980305;zipFiles=6;internalHashesVerified=$true;executableVersionVerified=$true;clientOrGameStarted=$false}|ConvertTo-Json|Set-Content -LiteralPath $proof -Encoding utf8
$files=@($package,$sum,$proof);$expected=@{}
foreach($file in $files){$item=Get-Item -LiteralPath $file;$expected[$item.Name]=@{size=$item.Length;digest='sha256:'+(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()}}
function ReadRelease {
 $json=& gh api ('repos/'+$repo+'/releases?per_page=100')
 if($LASTEXITCODE){throw 'Cannot read public releases'}
 $found=@(($json|ConvertFrom-Json)|Where-Object{$_.tag_name-ceq$tag})
 if($found.Count-gt1){throw 'Ambiguous release'}
 if($found.Count-eq1){return $found[0]};return $null
}
$release=ReadRelease
if($release-and-not$release.draft){
 $asset=@($release.assets|Where-Object{$_.name-ceq$name})
 if($asset.Count-ne1-or$asset[0].state-ne'uploaded'-or$asset[0].size-ne$size-or$asset[0].digest-cne('sha256:'+$sha)){throw 'Existing stable release differs; nothing overwritten'}
 Write-Output 'The exact stable client package is already published';exit 0
}
if($release-and$release.target_commitish-cne$env:GITHUB_SHA){throw 'Draft belongs to another source commit'}
if(-not$release){
 & gh release create $tag --repo $repo --target $env:GITHUB_SHA --draft --title 'UGSM Spielerclient 0.16.11' --notes-file '.github/player-release-notes-0.16.11.md'
 if($LASTEXITCODE){throw 'Cannot create release draft'}
}
$release=ReadRelease
foreach($file in $files){
 $item=Get-Item -LiteralPath $file;$present=@($release.assets|Where-Object{$_.name-ceq$item.Name})
 if($present.Count-gt0){
  if($present.Count-ne1-or$present[0].state-ne'uploaded'-or$present[0].size-ne$expected[$item.Name].size-or$present[0].digest-cne$expected[$item.Name].digest){throw 'Existing draft asset differs; nothing overwritten'}
 }else{
  & gh release upload $tag $file --repo $repo
  if($LASTEXITCODE){throw 'Upload failed; release remains a draft'}
 }
}
$verified=$false
for($attempt=0;$attempt-lt6;$attempt++){
 $release=ReadRelease;$valid=$true
 foreach($file in $files){
  $filename=[IO.Path]::GetFileName($file);$asset=@($release.assets|Where-Object{$_.name-ceq$filename})
  if($asset.Count-ne1-or$asset[0].state-ne'uploaded'-or$asset[0].size-ne$expected[$filename].size-or$asset[0].digest-cne$expected[$filename].digest){$valid=$false;break}
 }
 if($valid){$verified=$true;break};Start-Sleep -Seconds 5
}
if(-not$verified){throw 'Uploaded assets could not be verified; release remains a draft'}
$request=Join-Path $root 'publish.json'
[IO.File]::WriteAllText($request,(@{draft=$false;prerelease=$false;make_latest='true'}|ConvertTo-Json),[Text.UTF8Encoding]::new($false))
$json=& gh api --method PATCH ('repos/'+$repo+'/releases/'+$release.id) --input $request
if($LASTEXITCODE-or($json|ConvertFrom-Json).draft){throw 'Cannot publish verified release'}
Write-Output ('Published '+($json|ConvertFrom-Json).html_url)
