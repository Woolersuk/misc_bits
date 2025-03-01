# Set up deferred module loading
$FolPath = "C:\Alex\PowerShellProfileScripts"
# Dot-source modular scripts
. "$FolPath\AWSUtils.ps1"
. "$FolPath\GitUtils.ps1"
. "$FolPath\TerraformUtils.ps1"
. "$FolPath\KubernetesUtils.ps1"
. "$FolPath\NetworkUtils.ps1"
. "$FolPath\TeleportFunctions.ps1"

Set-Alias ~ (Get-Variable HOME).Value
#$myPat = "pat_token"
#$env:Pat = $myPat
Write-Host "/////////////////////// Teleport Shortcuts" -Fore Yellow
(get-alias taw*).DisplayName
(get-alias tl*).DisplayName
(get-alias tk*).DisplayName
kubectl completion powershell | Out-String | Invoke-Expression
