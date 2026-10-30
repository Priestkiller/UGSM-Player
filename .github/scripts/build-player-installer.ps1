param(
 [Parameter(Mandatory=$true)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,
 [Parameter(Mandatory=$true)][string]$VerifiedZip,
 [Parameter(Mandatory=$true)][ValidatePattern('^[a-f0-9]{64}$')][string]$ApprovedZipSha256,
 [Parameter(Mandatory=$true)][long]$ApprovedZipBytes,
 [Parameter(Mandatory=$true)][string]$OutputDirectory
)
$ErrorActionPreference='Stop'
$project=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$zip=[IO.Path]::GetFullPath($VerifiedZip)
if((Split-Path -Leaf $zip) -cne ('UGSM-Player-'+$Version+'-Windows-x64.zip') -or -not(Test-Path -LiteralPath $zip -PathType Leaf)){throw 'The exact verified public ZIP is required.'}
if((Get-Item -LiteralPath $zip).Length -ne $ApprovedZipBytes -or (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant() -cne $ApprovedZipSha256){throw 'The source ZIP no longer matches the approved package.'}
$output=[IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $output -Force | Out-Null
$setup=Join-Path $output ('UGSM-Player-'+$Version+'-Setup.exe')
& (Join-Path $project 'scripts/build-user-setup.ps1') -AppKind Player -Version $Version -PayloadZip $zip -OutputFile $setup | Out-Null
if(-not(Test-Path -LiteralPath $setup -PathType Leaf)){throw 'Setup build did not produce an artifact.'}
$build=Get-Content -LiteralPath ($setup+'.build.json') -Raw|ConvertFrom-Json
if($build.appId -cne 'UGSM.Player' -or $build.version -cne $Version -or $build.payloadSha256 -cne $ApprovedZipSha256 -or $build.files -ne 6 -or $build.installedOrLaunched -ne $false){throw 'Setup build proof does not match the approved package.'}
$item=Get-Item -LiteralPath $setup
$digest=(Get-FileHash -LiteralPath $setup -Algorithm SHA256).Hash.ToLowerInvariant()
if($build.sha256 -cne $digest -or $build.bytes -ne $item.Length -or $item.Length -gt 128MB){throw 'Setup output size/hash verification failed.'}
[pscustomobject]@{setup=$setup;proof=($setup+'.build.json');bytes=$item.Length;sha256=$digest;checksumLine=($digest+'  '+$item.Name)}
