param([Parameter(Mandatory=$true)][string]$WrapperFile,[Parameter(Mandatory=$true)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
$source=Join-Path $PSScriptRoot 'publish-player-0.16.18.ps1'
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile($source,[ref]$tokens,[ref]$errors)
if($errors.Count){throw 'Publisher does not parse.'}
$functions=@($ast.FindAll({param($n)$n -is [Management.Automation.Language.FunctionDefinitionAst] -and @('Assert-Player18ArtifactSpec','Receive-Player18CIArtifact','Copy-Player18CIArtifactPackage') -ccontains $n.Name},$false))
if($functions.Count -ne 3){throw 'Expected fixed artifact helpers are missing.'}
# Import helper declarations only; the real publisher and its GitHub calls never run.
foreach($function in $functions){Invoke-Expression $function.Extent.Text}
$spec=[pscustomobject]@{
 version='0.16.18';bytes=61447931L;sha256='78bd298ae34a0c424d58c676745fdc78696e9cec5f4ba48e91406404dc5480c3';
 sourceBuild='d6695e6f33e840ddb75c3acc284a759cbc232dba';sourceCommit='d6695e6f33e840ddb75c3acc284a759cbc232dba';sourceWorkflow=40742100776L;
 artifact=[pscustomobject]@{id=12840666559L;bytes=61460337L;sha256='3984bc9be77515c9993b25b2145e54fdaaeaa0fb62012b645882564435647856';url='https://sdmntprdenmarkeast.oaiusercontent.com/files/00000000-9b84-8210-bf95-53eb2160f79e/raw?fixture=offline'}
}
$checks=[Collections.Generic.List[string]]::new()
Assert-Player18ArtifactSpec $spec;$checks.Add('Exact approved source, run, artifact and ZIP pins accepted offline')
$mutations=@(
 @{name='wrong ZIP hash';change={$args[0].sha256=('0'*64)}},
 @{name='wrong ZIP size';change={$args[0].bytes--}},
 @{name='wrong source build';change={$args[0].sourceBuild=('0'*40)}},
 @{name='wrong source commit';change={$args[0].sourceCommit=('0'*40)}},
 @{name='wrong workflow';change={$args[0].sourceWorkflow--}},
 @{name='wrong artifact ID';change={$args[0].artifact.id--}},
 @{name='wrong wrapper hash';change={$args[0].artifact.sha256=('0'*64)}},
 @{name='wrong wrapper size';change={$args[0].artifact.bytes--}},
 @{name='wrong host';change={$args[0].artifact.url=$args[0].artifact.url.Replace('sdmntprdenmarkeast.oaiusercontent.com','example.com')}},
 @{name='HTTP';change={$args[0].artifact.url=$args[0].artifact.url.Replace('https:','http:')}},
 @{name='userinfo';change={$args[0].artifact.url=$args[0].artifact.url.Replace('https://','https://user@')}},
 @{name='fragment';change={$args[0].artifact.url+='#fragment'}},
 @{name='wrong raw path';change={$args[0].artifact.url=$args[0].artifact.url.Replace('/raw?','/other?')}},
 @{name='encoded path';change={$args[0].artifact.url=$args[0].artifact.url.Replace('/files/','/%66iles/')}},
 @{name='wrong explicit port';change={$args[0].artifact.url=$args[0].artifact.url.Replace('.com/','.com:444/')}},
 @{name='extra metadata';change={$args[0]|Add-Member extra 1}},
 @{name='old parts schema';change={$args[0]|Add-Member parts @();$args[0].PSObject.Properties.Remove('artifact')}}
)
foreach($case in $mutations){
 $bad=$spec|ConvertTo-Json -Depth 5|ConvertFrom-Json;& $case.change $bad
 $rejected=$false;try{Assert-Player18ArtifactSpec $bad}catch{$rejected=$true}
 if(-not $rejected){throw ('Invalid specification accepted: '+$case.name)}
 $checks.Add(('Rejected before networking: '+$case.name))
}
$receiver=($functions|Where-Object{$_.Name -ceq 'Receive-Player18CIArtifact'}).Extent.Text
if($receiver.IndexOf('Assert-Player18ArtifactSpec $Spec') -lt 0 -or $receiver.IndexOf('Assert-Player18ArtifactSpec $Spec') -gt $receiver.IndexOf('[Net.Http.HttpClient]::new') -or -not $receiver.Contains('$handler.AllowAutoRedirect=$false') -or $receiver.Contains('GH_TOKEN') -or $receiver.Contains('Authorization')){throw 'Fixed download must validate before network, refuse redirects and omit job credentials.'}
$checks.Add('Receiver validates first, rejects redirects and never uses GitHub credentials')
$output=[IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $output -Force|Out-Null
$package=Join-Path $output ('verified-client-'+[guid]::NewGuid().ToString('N')+'.zip')
try{
 Copy-Player18CIArtifactPackage $spec ([IO.Path]::GetFullPath($WrapperFile)) $package
 if((Get-Item -LiteralPath $package).Length -ne $spec.bytes -or (Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash.ToLowerInvariant() -cne $spec.sha256){throw 'Copied client ZIP is not the exact approved CI ZIP.'}
 $checks.Add('Verified local wrapper has exactly2 bounded root members; copied only exact approved client ZIP')
 $zip=[IO.Compression.ZipFile]::OpenRead($package)
 try{if($zip.Entries.Count -ne 6){throw 'Approved client inventory differs.'}}finally{$zip.Dispose()}
 $checks.Add('Approved inner client ZIP retains all6 expected members')
}finally{if(Test-Path -LiteralPath $package){Remove-Item -LiteralPath $package -Force}}
$report=[ordered]@{passed=$true;checks=@($checks);count=$checks.Count;networkUsed=$false;githubMutated=$false;desktopStarted=$false;gameStarted=$false;checkedAt=[DateTime]::UtcNow.ToString('o')}
[IO.File]::WriteAllText((Join-Path $output 'artifact-source-verification.json'),($report|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
$report|ConvertTo-Json -Depth 5
