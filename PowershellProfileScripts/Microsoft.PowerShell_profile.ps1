# Set up deferred module loading
$FolPath = "C:\Alex\PowerShellProfileScripts"
$scriptFiles = Get-ChildItem -Path $FolPath -Filter *.ps1
foreach ($script in $scriptFiles) {
  . $script.FullName
}

Set-Alias ~ (Get-Variable HOME).Value
#$myPat = "pat_token"
#$env:Pat = $myPat
Write-Host "/////////////////////// Teleport Shortcuts" -Fore Yellow
(get-alias taw*).DisplayName
(get-alias tl*).DisplayName
(get-alias tk*).DisplayName
kubectl completion powershell | Out-String | Invoke-Expression
