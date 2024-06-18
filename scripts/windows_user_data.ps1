<powershell>
# Parameters for the new user
$username = "AdminUser"
$password = "SecureP@ssword123"

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create the new user
New-LocalUser -Name $username -Password $securePassword -FullName "Administrator" -Description "Admin User for WinRM"

# Add the new user to the administrators group
Add-LocalGroupMember -Group "Administrators" -Member $username

# Create a new listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS

# Set the winrm service to start automatically
Set-Service -Name winrm -StartupType Automatic

# Allow basic authentication for winrm
winrm set winrm/config/service/Auth @{Basic="true"}

# Allow unencrypted communication for winrm
winrm set winrm/config/service @{AllowUnencrypted="true"}

# Create self-signed certificate
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My

# Create HTTPS listener with the certificate
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="$env:COMPUTERNAME";CertificateThumbprint="$($cert.Thumbprint)"}

# Set winrm service configuration
winrm set winrm/config/client @{TrustedHosts="*"}

# Enable firewall rule for WinRM
New-NetFirewallRule -DisplayName "WinRM-HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5986

# Open port 5986 for WinRM
netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=in localport=5986 action=allow
</powershell>
