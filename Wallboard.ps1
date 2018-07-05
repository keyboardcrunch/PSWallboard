<#
.SYNOPSIS
    Wallboard script to rotate through browser tabs and/or Win10 desktops.

.DESCRIPTION
    Wallboard script to rotate through browser tabs and/or Win10 desktops.

.EXAMPLE
    Wallboard.ps1

.NOTES
    File Name: Wallboard.ps1
    Author: keyboardcrunch
#>

# SendKeys Docs - https://msdn.microsoft.com/en-us/library/system.windows.forms.sendkeys(v=vs.110).aspx

Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
Import-Module "C:\WindowsPowerShell\Modules\VirtualDesktop.ps1"

$Rotate = "300" # Seconds between dashboard rotation
$tabcount = 0
$appcount = 0
$apps_enabled = $false
$User = "wallboardsvc"
$Sites = @(
"https://dashboard.corp.com",
"https://nessus.corp.com/#dashboard/1"
)
$Apps = @()
If ($Apps.Count -eq 0) {$apps_enabled = $false}

Function Setup {
    $D1 = Get-Desktop
    # Open all the defined sites/dashboards
    ForEach ($Site in $Sites) {
        $null = [System.Diagnostics.Process]::Start($Site)
        Start-Sleep -Seconds 3
    }

    # Full Screen Chrome
    [Microsoft.VisualBasic.Interaction]::AppActivate(“Google Chrome”)
    [System.Windows.Forms.SendKeys]::SendWait(“{F11}”)
    
    If (!$apps_enabled -eq $false) {
        # Create second virtual desktop
        New-Desktop | Switch-Desktop
        ForEach ($App in $Apps) {
            Start-Process $App -Credential $User -WindowStyle Maximized
        }
        Switch-Desktop 0
    }
}

Function Desktop1 {
    Switch-Desktop 0 # Jump to Desktop1
    [Microsoft.VisualBasic.Interaction]::AppActivate(“Google Chrome”)
    [System.Windows.Forms.SendKeys]::SendWait(“^{TAB}”)
    [System.Windows.Forms.SendKeys]::SendWait(“{F5}”)
    Start-Sleep -Seconds $Rotate
}

Function Desktop2 {
    # We can alt-tab or AppActivate apps in this desktop
    Switch-Desktop 1 # Jump to Desktop2
    Start-Sleep -Seconds $Rotate
}


# Setup desktops
Setup


While ( $true ) {
    While ( $tabcount -lt 4 ) { # Desktop1 - Rotate through Chrome tabs
        Desktop1
        $tabcount += 1
    }
    If ( $tabcount -eq 4 ) { # Desktop2 - Rotate through apps
        If (!$apps_enabled -eq $false) {
            Desktop2
        }
        $tabcount = 0
    }
}