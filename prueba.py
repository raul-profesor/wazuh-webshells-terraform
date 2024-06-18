import urllib3
from winrm.protocol import Protocol

urllib3.disable_warnings()

# Example usage
endpoint = 'http://54.237.116.252:5985/wsman'
username = 'AdminUser'
password = 'SecureP@ssword123'

p = Protocol(
    endpoint=endpoint,
    transport='ntlm',
    username=username,
    password=password,
    server_cert_validation='ignore'  # Ignore SSL certificate validation
)

shell_id = p.open_shell()
