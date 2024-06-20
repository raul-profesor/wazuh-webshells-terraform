import urllib3
from winrm.protocol import Protocol

urllib3.disable_warnings()

# Example usage
endpoint = 'https://54.86.67.129:5986/wsman'
username = 'AdminUser'
password = 'SecureP@ssword123'

p = Protocol(
    endpoint=endpoint,
    transport='basic',
    username=username,
    password=password,
    server_cert_validation='ignore'  # Ignore SSL certificate validation
)

shell_id = p.open_shell()
