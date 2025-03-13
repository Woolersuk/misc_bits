
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

function ListAllEnvVars {
	Get-ChildItem env:* | sort-object name
}

Set-Alias addtask AddWorkItemTask -Force
Set-Alias approvepr ApprovePullRequest -Force
Set-Alias getpr getPrInfo -Force
Set-Alias getticket getWorkItemFields -Force
Set-Alias getvars ListAllEnvVars -Force
Set-Alias cdc Clear-DnsClientCache -Force
Set-Alias cleandl -Value CleanDownloads -Force
Set-Alias dig Resolve-DNSName -Force
Set-Alias elan ChangetoLAN -Force
Set-Alias ewifi ChangetoWifi -Force
Set-Alias findit FindInCurrentPath -Force
Set-Alias getmyextip GetMyExternalIP -Force
Set-Alias ipcfg Get-NetIPConfiguration -Force
Set-Alias myextip GetMyExternalIP -Force
Set-Alias nsl Resolve-DNSName -Force
Set-Alias removemepr removeMeasReviewer -Force
Set-Alias rdp StartRDP -Force
Set-Alias rdpb StartRDBuild -Force
Set-Alias rdt StartRDBuild2 -Force
Set-Alias rebootit RebootInstance -Force
Set-Alias vmlan ChangeVMToLan -Force
Set-Alias vmwifi ChangeVMToWifi -Force