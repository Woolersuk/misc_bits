# Teleport CLI shortcuts for PowerShell
function Set-TeleportLoginKubeAdmin { tsh kube login headquarter-admin-eks-green --proxy=youlend.teleport.sh:443 --auth=ad }
function Set-TeleportLoginKubeDev { tsh kube login aslive-dev-eks-green --proxy=youlend.teleport.sh:443 --auth=ad }
function Set-TeleportLoginKubeProd { tsh kube login live-prod-eks-green --proxy=youlend.teleport.sh:443 --auth=ad }
function Set-TeleportLoginKubeSandbox { tsh kube login aslive-sandbox-eks-green --proxy=youlend.teleport.sh:443 --auth=ad }
function Set-TeleportLoginKubeStaging { tsh kube login aslive-staging-eks-green --proxy=youlend.teleport.sh:443 --auth=ad }
function Set-TeleportLoginKubeUSProd { tsh kube login live-usprod-eks-green --proxy=youlend.teleport.sh:443 --auth=ad }
function Set-TeleportLogin { tsh login --auth=ad --proxy=youlend.teleport.sh:443 }
function Set-TeleportLogout { tsh logout }
function Set-TeleportLogoutApps { tsh logout apps }
function Get-TeleportStatus { tsh status }

# Quickly obtain AWS credentials via Teleport
function Get-TeleportAWS { tsh aws }

# Main Kubernetes function
function Invoke-TeleportKube {
    param(
        [Parameter()]
        [switch]$c,
        
        [Parameter()]
        [switch]$l,
        
        [Parameter(Position = 0)]
        [string]$Command,
        
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    # Handle switches first
    if ($c) { 
        Invoke-TeleportKubeInteractiveLogin
        return 
    }
    if ($l) { 
        tsh kube ls -f text
        return 
    }

    # Handle commands
    switch ($Command) {
        "ls" { tsh kube ls -f text }
        "login" {
            if ($Arguments -and $Arguments[0] -eq "-c") {
                Invoke-TeleportKubeInteractiveLogin
            }
            else {
                tsh kube login $Arguments
            }
        }
        "sessions" { tsh kube sessions $Arguments }
        "exec" { tsh kube exec $Arguments }
        "join" { tsh kube join $Arguments }
        $null { Write-Host "Usage: tkube {-c | -l | ls | login [cluster_name | -c] | sessions | exec | join }" }
        default {
            Write-Host "Usage: tkube {-c | -l | ls | login [cluster_name | -c] | sessions | exec | join }"
        }
    }
}

# Main function for Teleport apps
function Invoke-TeleportAWS {
    param(
        [Parameter()]
        [switch]$c,
        
        [Parameter()]
        [switch]$l,
        
        [Parameter(Position = 0)]
        [string]$Command,
        
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    # Handle switches first
    if ($c) { 
        Invoke-TeleportAWSInteractiveLogin
        return 
    }
    if ($l) { 
        tsh apps ls -f text
        return 
    }

    # Handle commands
    switch ($Command) {
        "login" {
            if ($Arguments -and $Arguments[0] -eq "-c") {
                Invoke-TeleportAWSInteractiveLogin
            }
            else {
                tsh apps login $Arguments
            }
            return
        }
        $null { Write-Host "Usage: tawsp { -c | -l | login [app_name | -c] }" }
        default {
            Write-Host "Usage: tawsp { -c | -l | login [app_name | -c] }"
        }
    }
}

# Helper function for interactive app login with AWS role selection
function Invoke-TeleportAWSInteractiveLogin {
    # Get the list of apps
    $output = tsh apps ls -f text
    if (-not $output) {
        Write-Host "No apps available."
        return 1
    }

    $lines = $output -split "`n"
    $header = $lines[0..1]
    $apps = $lines[2..($lines.Length-1)]

    if (-not $apps) {
        Write-Host "No apps available."
        return 1
    }

    # Display header and numbered list of apps
    $header | ForEach-Object { Write-Host $_ }
    $appsList = $apps | Where-Object { $_ -match '\S' } | ForEach-Object -Begin {$i=1} -Process {
        Write-Host ("{0,2}. {1}" -f $i++, $_)
    }

    # Prompt for app selection
    $appChoice = Read-Host "Choose app to login (number)"
    if (-not $appChoice) {
        Write-Host "No selection made. Exiting."
        return 1
    }

    $chosenLine = $apps[$appChoice - 1]
    if (-not $chosenLine) {
        Write-Host "Invalid selection."
        return 1
    }

    # If the first column is ">", use the second column; otherwise, use the first
    $app = if ($chosenLine -match '^>') {
        ($chosenLine -split '\s+')[1]
    } else {
        ($chosenLine -split '\s+')[0]
    }

    Write-Host "Selected app: $app"

    # Log out of the selected app to force fresh AWS role output
    Write-Host "Logging out of app: $app..."
    tsh apps logout $app > $null 2>&1

    # Run tsh apps login to capture the AWS roles listing
    $loginOutput = tsh apps login $app 2>&1

    # Extract the AWS roles section
    $roleSection = $loginOutput | Select-String -Pattern "Available AWS roles:" -Context 0,20
    if (-not $roleSection) {
        Write-Host "No AWS roles info found. Attempting direct login..."
        tsh apps login $app
        return
    }

    $roleLines = $roleSection.Context.PostContext | Where-Object { $_ -match '\S' -and $_ -notmatch 'ERROR:' }
    $roleHeader = $roleLines[0..1]
    $rolesList = $roleLines[2..($roleLines.Length-1)]

    if (-not $rolesList) {
        Write-Host "No roles found in the AWS roles listing."
        Write-Host "Logging you into app '$app' without specifying an AWS role."
        tsh apps login $app
        return
    }

    Write-Host "Available AWS roles:"
    $roleHeader | ForEach-Object { Write-Host $_ }
    $rolesList | ForEach-Object -Begin {$i=1} -Process {
        Write-Host ("{0,2}. {1}" -f $i++, $_)
    }

    # Prompt for role selection
    $roleChoice = Read-Host "Choose AWS role (number)"
    if (-not $roleChoice) {
        Write-Host "No selection made. Exiting."
        return 1
    }

    $chosenRoleLine = $rolesList[$roleChoice - 1]
    if (-not $chosenRoleLine) {
        Write-Host "Invalid selection."
        return 1
    }

    $roleName = ($chosenRoleLine -split '\s+')[0]
    if (-not $roleName) {
        Write-Host "Invalid selection."
        return 1
    }

    Write-Host "Logging you into app: $app with AWS role: $roleName"
    tsh apps login $app --aws-role $roleName
}

# Helper function for interactive Kubernetes login
function Invoke-TeleportKubeInteractiveLogin {
    $output = tsh kube ls -f text
    if (-not $output) {
        Write-Host "No Kubernetes clusters available."
        return 1
    }

    $lines = $output -split "`n"
    $header = $lines[0..1]
    $clusters = $lines[2..($lines.Length-1)]

    if (-not $clusters) {
        Write-Host "No Kubernetes clusters available."
        return 1
    }

    # Show header and numbered list of clusters
    $header | ForEach-Object { Write-Host $_ }
    $clusterList = $clusters | Where-Object { $_ -match '\S' } | ForEach-Object -Begin {$i=1} -Process {
        Write-Host ("{0,2}. {1}" -f $i++, $_)
    }

    # Prompt for selection
    $choice = Read-Host "Choose cluster to login (number)"
    if (-not $choice) {
        Write-Host "No selection made. Exiting."
        return 1
    }

    $chosenLine = $clusters[$choice - 1]
    if (-not $chosenLine) {
        Write-Host "Invalid selection."
        return 1
    }

    $cluster = ($chosenLine -split '\s+')[0]
    if (-not $cluster) {
        Write-Host "Invalid selection."
        return 1
    }

    Write-Host "Logging you into cluster: $cluster"
    tsh kube login $cluster
}


Set-Alias -Name taws -Value Get-TeleportAWS
Set-Alias -Name tawsp -Value Invoke-TeleportAWS
Set-Alias -Name tkube -Value Invoke-TeleportKube
Set-Alias -Name tl -Value Set-TeleportLogin
Set-Alias -Name tla -Value Set-TeleportLogoutApps
Set-Alias -Name tlo -Value Set-TeleportLogout

Set-Alias -Name tkadmin -Value Set-TeleportLoginKubeAdmin
Set-Alias -Name tkdev -Value Set-TeleportLoginKubeDev
Set-Alias -Name tkprod -Value Set-TeleportLoginKubeProd
Set-Alias -Name tksandbox -Value Set-TeleportLoginKubeSandbox
Set-Alias -Name tkstaging -Value Set-TeleportLoginKubeStaging
Set-Alias -Name tkusprod -Value Set-TeleportLoginKubeUSProd

Set-Alias -Name tstat -Value Get-TeleportStatus