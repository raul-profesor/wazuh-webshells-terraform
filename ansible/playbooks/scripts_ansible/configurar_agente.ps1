# Define colors
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Reset = "`e[0m"

# Define the file path
$OSSEC_CONF = "C:\Program Files (x86)\ossec-agent\ossec.conf"

# Define the new <directories> line to be added within the <syscheck> block
$DIRECTORIES_LINE = "`t`t<directories realtime=`"yes`" check_all=`"yes`" report_changes=`"yes`">C:\inetpub\wwwroot</directories>"

# Define the <ossec_config> block to be added at the end of the file
$OSSEC_CONFIG_BLOCK = @"
<ossec_config>
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>
</ossec_config>
"@

# Function to insert line into file
function Insert-Line {
    param (
        [string]$file,
        [string]$pattern,
        [string]$newline
    )

    $content = Get-Content $file
    $inserted = $false
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match $pattern) {
            $content = $content[0..$i] + $newline + $content[$i+1..$content.Count]
            $inserted = $true
            break
        }
    }
    if ($inserted) {
        Set-Content $file $content -Force
        return $true
    }
    return $false
}

# Check if the <directories> line already exists within the <syscheck> block
if (Select-String -Path $OSSEC_CONF -Pattern "<directories.*>C:\inetpub\wwwroot</directories>") {
    Write-Host "${Yellow}The <directories> line already exists in the <syscheck> block.${Reset}"
} else {
    # Insert the <directories> line within the <syscheck> block
    if (Insert-Line -file $OSSEC_CONF -pattern "<syscheck>" -newline $DIRECTORIES_LINE) {
        Write-Host "${Green}Added the <directories> line to the <syscheck> block.${Reset}"
    } else {
        Write-Host "${Red}Failed to add the <directories> line to the <syscheck> block.${Reset}"
    }
}

# Check if the <ossec_config> block already exists at the end of the file
if (Select-String -Path $OSSEC_CONF -Pattern "<location>Microsoft-Windows-Sysmon/Operational</location>") {
    Write-Host "${Yellow}The <ossec_config> block already exists at the end of the file.${Reset}"
} else {
    # Add the <ossec_config> block at the end of the file
    Add-Content -Path $OSSEC_CONF -Value $OSSEC_CONFIG_BLOCK
    Write-Host "${Green}Added the <ossec_config> block to the end of the file.${Reset}"
}

Write-Host "${Green}Configuration updates completed.${Reset}"
