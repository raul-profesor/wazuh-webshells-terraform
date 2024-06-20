<powershell>
# Check if running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Script is not running as Administrator. Attempting to elevate privileges..."
        try {
            # Start a new PowerShell process with elevated privileges
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
            exit
        } catch {
            Write-Error "Failed to start PowerShell with elevated privileges: $_"
            exit 1
        }
    }

    # Define log file path
    $logFile = "C:\simple_script.log"

    # Write a message to the log file
    "Script executed at $(Get-Date)" | Out-File -FilePath $logFile -Append
</powershell>
<persist>true</persist>