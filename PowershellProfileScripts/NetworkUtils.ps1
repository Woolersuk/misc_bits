
function ChangetoWifi {
  Get-NetAdapter -Name Laptop-Eth | Disable-NetAdapter -Confirm:$False
  Get-VM "ubuntu" | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "Wifi"
}

function ChangetoLAN {
  Get-NetAdapter -Name Laptop-Eth | Enable-NetAdapter
  Get-VM "ubuntu" | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "Eth-Switch"
}

function NicList { Get-NetIPInterface | Sort-Object ifIndex | Format-Table -AutoSize }

function GetMyExternalIP {
  $MyExternalIP = (Invoke-WebRequest -Uri "https://api.ipify.org/").Content + "/32"
  Write-Host "External IP: $MyExternalIP"
}

Function CleanDownloads {
  Remove-Item "C:\AlexW\Downloads\*.yaml"
  Remove-Item "C:\AlexW\Downloads\*.rdp"
  Remove-Item "C:\AlexW\Downloads\*.zip"
}


function FindInCurrentPath { param ([string] $i); Get-ChildItem -Recurse | Select-String -Pattern $i | Select-Object -Property FileName, Line }
function ApprovePullRequest { param ([string] $i); az repos pr set-vote --id $i --vote approve }
function getPrInfo { param ([string] $i); az repos pr show --id $i | ConvertFrom-Json | Format-List }
function getWorkItemFields {
  param ([string]$i)
  $workItem = az boards work-item show --id $i | ConvertFrom-Json
  $fields = $workItem.fields.PSObject.Properties | Select-Object Name, Value
  $fields | Sort-Object Name | Format-Table Name, Value -AutoSize
}
function removeMeasReviewer { param ([string] $i); az repos pr reviewer remove --id $i --reviewers alex.woolsey@youlend.com }
function AddWorkItemTask { 
  param (
    [string] $Parent,
    [string] $Title,
    [string] $N
  )
  $workItemOutput = az boards work-item create --type Task --title $Title --assigned-to alex.woolsey@youlend.com --area "Youlend-Infrastructure\Dev Enablement" --iteration "Youlend-Infrastructure\Dev Enablement Sprint $N"
  $workItem = $workItemOutput | ConvertFrom-Json
  $workItemId = $workItem.id
  Write-Host "Created: $workItemId" -Fore Cyan
  if ($workItemId) {
    az boards work-item relation add --id $workItemId --relation-type parent --target-id $Parent
  } else {
    Write-Error "Failed to create work item or retrieve its ID."
  }
}

function gitCloneYLDataRepo {
  param ([string]$i)
  git clone https://dev.azure.com/Youlend/Youlend-DataAnalytics/_git/$i C:\GIT\YL_Data\$i
}

function gitCloneYLInfraRepo {
  param ([string]$i)
  git clone https://dev.azure.com/Youlend/Youlend-Infrastructure/_git/$i C:\GIT\YL_Infra\$i
}

function gitCloneYLRepo {
  param ([string]$i)
  git clone https://dev.azure.com/Youlend/Youlend/_git/$i C:\GIT\YL_\$i
}

New-Alias -Name "addtask" AddWorkItemTask -Force
New-Alias -Name "approvepr" ApprovePullRequest -Force
New-Alias -Name "gcyl" gitCloneYLRepo
New-Alias -Name "gcyld" gitCloneYLDataRepo
New-Alias -Name "gcyli" gitCloneYLInfraRepo
New-Alias -Name "getpr" getPrInfo -Force
New-Alias -Name "getticket" getWorkItemFields -Force
New-Alias -Name "cdc" Clear-DnsClientCache -Force
New-Alias -Name "cleandl" -Value CleanDownloads -Force
New-Alias -Name "dig" Resolve-DNSName -Force
New-Alias -Name "elan" ChangetoLAN -Force
New-Alias -Name "ewifi" ChangetoWifi -Force
New-Alias -Name "findit" FindInCurrentPath -Force
New-Alias -Name "getmyextip" GetMyExternalIP -Force
New-Alias -Name "ipcfg" Get-NetIPConfiguration -Force
New-Alias -Name "myextip" GetMyExternalIP -Force
New-Alias -Name "nsl" Resolve-DNSName -Force
New-Alias -Name "removemepr" removeMeasReviewer -Force
New-Alias -Name "rdp" StartRDP -Force
New-Alias -Name "rdpb" StartRDBuild -Force
New-Alias -Name "rdt" StartRDBuild2 -Force
New-Alias -Name "rebootit" RebootInstance -Force
New-Alias -Name "vmlan" ChangeVMToLan -Force
New-Alias -Name "vmwifi" ChangeVMToWifi -Force