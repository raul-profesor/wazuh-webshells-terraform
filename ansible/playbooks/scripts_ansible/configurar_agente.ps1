
$OSSEC_CONF = "C:\Program Files (x86)\ossec-agent\ossec.conf"
$DIRECTORIES_LINE = "`t`t<directories realtime=`"yes`" check_all=`"yes`" report_changes=`"yes`">C:\inetpub\wwwroot</directories>"

$OSSEC_CONFIG_BLOCK = @"
<ossec_config>
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>
</ossec_config>
"@

# Función para insertar la linea en el archivo
function Insert-Line {
    param (
        [string]$file,
        [string]$pattern,
        [string]$newline
    )

    $content = Get-Content $file
    $newContent = @()
    $inserted = $false

    foreach ($line in $content) {
        $newContent += $line
        if ($line -match $pattern -and -not $inserted) {
            $newContent += $newline
            $inserted = $true
        }
    }

    if ($inserted) {
        Set-Content $file $newContent -Force
        return $true
    }
    return $false
}

if (Select-String -Path $OSSEC_CONF -Pattern "<directories.*>C:\\inetpub\\wwwroot</directories>") {
    Write-Host "${Yellow}The <directories> line already exists in the <syscheck> block.${Reset}"
} else {
    if (Insert-Line -file $OSSEC_CONF -pattern "<syscheck>" -newline $DIRECTORIES_LINE) {
        Write-Host "${Green}Added the <directories> line to the <syscheck> block.${Reset}"
    } else {
        Write-Host "${Red}Failed to add the <directories> line to the <syscheck> block.${Reset}"
    }
}

if (Select-String -Path $OSSEC_CONF -Pattern "<location>Microsoft-Windows-Sysmon/Operational</location>") {
    Write-Host "${Yellow}The <ossec_config> block already exists at the end of the file.${Reset}"
} else {
     Add-Content -Path $OSSEC_CONF -Value $OSSEC_CONFIG_BLOCK
    Write-Host "${Green}Added the <ossec_config> block to the end of the file.${Reset}"
}

Write-Host "${Green}Configuration updates completed.${Reset}"
