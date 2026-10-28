# Local, bounded reconstruction only. The fixed publisher supplies the reader;
# release metadata can nominate pinned public data blobs, never executable code.
function Get-PlayerReleaseSHA256([byte[]]$Bytes) {
 $hash=[Security.Cryptography.SHA256]::Create()
 try {return [BitConverter]::ToString($hash.ComputeHash($Bytes)).Replace('-','').ToLowerInvariant()}
 finally {$hash.Dispose()}
}

function Assert-PlayerReleaseParts($Parts,[long]$Size,[string]$SHA256) {
 if($Size -lt 1 -or $Size -gt 128MB -or $SHA256 -cnotmatch '\A[a-f0-9]{64}\z' -or $Parts -isnot [array] -or $Parts.Count -lt 1 -or $Parts.Count -gt 16){throw 'PENDING: approved public ZIP parts, exact SHA256 and positive full size must be pinned first.'}
 $total=0L
 foreach($part in $Parts){
  $names=@($part.PSObject.Properties|ForEach-Object{$_.Name})
  if($part -isnot [pscustomobject] -or $names.Count -ne 3 -or $names -cnotcontains 'blob' -or $names -cnotcontains 'bytes' -or $names -cnotcontains 'sha256' -or $part.blob -isnot [string] -or $part.sha256 -isnot [string] -or $part.blob -cnotmatch '\A[a-f0-9]{40}\z' -or $part.sha256 -cnotmatch '\A[a-f0-9]{64}\z' -or ($part.bytes -isnot [int] -and $part.bytes -isnot [long]) -or $part.bytes -lt 1 -or $part.bytes -gt 15MB){throw 'PENDING: every ordered public ZIP part needs an exact raw Git blob SHA, positive size up to 15 MiB, and SHA256.'}
  $total+=[long]$part.bytes
  if($total -gt $Size){throw 'Public ZIP parts exceed the pinned full size.'}
 }
 if($total -ne $Size){throw 'Public ZIP part sizes do not equal the pinned full size.'}
}

function Join-PlayerReleaseParts($Parts,[long]$Size,[string]$SHA256,[string]$OutputFile,[scriptblock]$ReadPart) {
 Assert-PlayerReleaseParts $Parts $Size $SHA256
 if(-not $ReadPart){throw 'A fixed local public-part reader is required.'}
 $output=[IO.File]::Open($OutputFile,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
 try {
  $written=0L
  foreach($part in $Parts){
   $bytes=& $ReadPart $part
   if($bytes -isnot [byte[]] -or $bytes.LongLength -ne [long]$part.bytes -or (Get-PlayerReleaseSHA256 $bytes) -cne [string]$part.sha256){throw 'Public ZIP part size or SHA256 mismatch.'}
   $output.Write($bytes,0,$bytes.Length)
   $written+=$bytes.LongLength
   $bytes=$null
  }
  if($written -ne $Size){throw 'Reconstructed public ZIP size differs.'}
 }finally {$output.Dispose()}
 if((Get-Item -LiteralPath $OutputFile).Length -ne $Size -or (Get-FileHash -LiteralPath $OutputFile -Algorithm SHA256).Hash.ToLowerInvariant() -cne $SHA256){throw 'Reconstructed public ZIP size or SHA256 mismatch.'}
}
