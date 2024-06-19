# Parameters
$certSubject = "CN=$env:COMPUTERNAME"
$port = 5986
$username = "AdminUser"
$password = "SecureP@ssword123"

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create the new user
New-LocalUser -Name $username -Password $securePassword -FullName "Administrator" -Description "Admin User for WinRM"

# Add the new user to the administrators group
Add-LocalGroupMember -Group "Administrators" -Member $username

# Create self-signed certificate
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(10)

# Configure WinRM
# Set the WinRM service to start automatically
Set-Service -Name winrm -StartupType Automatic

# Start the WinRM service
Start-Service -Name winrm

# Allow basic and Negotiate authentication
winrm set winrm/config/service/auth '@{Basic="true";Negotiate="true"}'

# Allow unencrypted communication
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# Create HTTPS listener with the self-signed certificate
$thumbprint = $cert.Thumbprint
#$hostname = $env:COMPUTERNAME
#$listenerCommand = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=`"$hostname`";CertificateThumbprint=`"$thumbprint`";Port=`"$port`"}"
#Invoke-Expression -Command $listenerCommand

$selector_set = @{
    Address = "*"
    Transport = "HTTPS"
}
$value_set = @{
    CertificateThumbprint = "$thumbprint"
}

New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set


# Set the trusted hosts to '*'
winrm set winrm/config/client '@{TrustedHosts="*"}'

# Enable firewall rule for WinRM HTTPS
New-NetFirewallRule -DisplayName "Permitir WinRM-HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port

# Restart the WinRM service
Restart-Service -Name winrm

