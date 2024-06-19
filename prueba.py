import urllib3
from winrm.protocol import Protocol

urllib3.disable_warnings()

# Example usage
endpoint = 'https://34.229.55.190:5986/wsman'
username = 'AdminUser3'
password = 'profesor.1'

p = Protocol(
    endpoint=endpoint,
    transport='ntlm',
    username=username,
    password=password,
    server_cert_validation='ignore'  # Ignore SSL certificate validation
)

shell_id = p.open_shell()
