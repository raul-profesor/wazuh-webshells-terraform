<powershell>

    # Define the log file
    # Example Windows User Data Script to run as administrator
    # Set execution policy
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

    # Check if running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You are not running this script as Administrator. It may fail."
    }

    $logFile = "C:\winrm_setup.log"

    # Function to log messages
    function Log-Message {
        param (
            [string]$message
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp - $message"
        Add-Content -Path $logFile -Value $logEntry
    }

    # Log start
    Log-Message "Script execution started"

    try {
        # Parameters
        $certSubject = "CN=$env:COMPUTERNAME"
        $port = 5986
        $username = "AdminUser"
        $password = "SecureP@ssword123"
        
        # Convert the password to a secure string
        Log-Message "Converting password to secure string"
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        
        # Create the new user
        Log-Message "Creating new user $username"
        New-LocalUser -Name $username -Password $securePassword -FullName "Administrator" -Description "Admin User for WinRM"
        
        # Add the new user to the administrators group
        Log-Message "Adding user $username to Administrators group"
        Add-LocalGroupMember -Group "Administrators" -Member $username
        
        # Create self-signed certificate
        Log-Message "Creating self-signed certificate"
        $cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(10)
        
        # Configure WinRM
        Log-Message "Setting WinRM service to start automatically"
        Set-Service -Name winrm -StartupType Automatic
        
        Log-Message "Starting WinRM service"
        Start-Service -Name winrm
        
        Log-Message "Allowing basic and Negotiate authentication"
        winrm set winrm/config/service/auth '@{Basic="true";Negotiate="true"}'
        
        Log-Message "Disallowing unencrypted communication"
        winrm set winrm/config/service '@{AllowUnencrypted="false"}'
        
        # Create HTTPS listener with the self-signed certificate
        Log-Message "Creating HTTPS listener"
        $thumbprint = $cert.Thumbprint
        $selector_set = @{
            Address = "*"
            Transport = "HTTPS"
        }
        $value_set = @{
            CertificateThumbprint = "$thumbprint"
            Port = $port
        }
        New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set
        
        # Set the trusted hosts to '*'
        Log-Message "Setting trusted hosts to *"
        winrm set winrm/config/client '@{TrustedHosts="*"}'
        
        # Enable firewall rule for WinRM HTTPS
        Log-Message "Enabling firewall rule for WinRM HTTPS"
        New-NetFirewallRule -DisplayName "Permitir WinRM-HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port
        
        # Restart the WinRM service
        Log-Message "Restarting WinRM service"
        Restart-Service -Name winrm
        
        Log-Message "Script execution completed successfully"
    } catch {
        Log-Message "Error: $_"
    }
    <powershell>
    <persist>true</persist>