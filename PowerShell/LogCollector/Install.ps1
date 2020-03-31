<#
.DESCRIPTION
Basic installation script for Inventory Collector. It faciliates creation of
the configuration file for the script as well as setting up the scheduled
task to run the script.

.PARAMETER InWmi
Switch to enable collection from WMI. Requires the WMIConfigXML parameter to
be configured as well.

.PARAMETER WMIConfigXML
The path (web or local/share) to the Configuration file for WMI data
gathering.

.PARAMETER InAddRemovePrograms
Switch to enable collecting Add/Remove Program information from the registry.

.PARAMETER OutLogAnalytics
Switch to enable output to Azure Monitor Log Analytics.

.PARAMETER LogAnalyticsWorkspaceId
The ID of the Log Analytics workspace you wish to add data to.

.PARAMETER LogAnalyticsWorkspacePrimaryKey
The primary key of the Log Analytics workspace you wish to add data to.

.PARAMETER EncryptLogAnalyticsWorkspacePrimaryKey
Switch to encrypt the key (as it is stored in the configuration XML) using
SecureString with the SYSTEM account.

.PARAMETER RunInterval
How often should inventory collection run. This can only run as often as
once per hour as the scheduled task runs once per hour and validates the
last run time before proceeding with inventory collection.

.PARAMETER InstallLocation
The location the script should be installed to. Defaults to $ENV:WinDir\InventoryCollector

.NOTES
Written By: Nathan Ziehnert
Twitter: @theznerd
Blog: https://z-nerd.com

.LINK
https://github.com/theznerd/InventoryCollector
#>
param(
    [switch]$InWMI,
    [string]$WMIConfigXML,

    [switch]$InAddRemovePrograms,

    [switch]$OutLogAnalytics,
    [string]$LogAnalyticsWorkspaceId,
    [string]$LogAnalyticsWorkspacePrimaryKey,
    [switch]$EncryptLogAnalyticsWorkspacePrimaryKey,

    [int]$RunInterval,

    [string]$InstallLocation = "$ENV:windir\InventoryCollector"
)

## Restart the script in 64-bit mode if started with 32-bit PowerShell on a 64-bit host
$argsString = ""
If ($ENV:PROCESSOR_ARCHITEW6432 -eq “AMD64”) {
    Try {
        foreach($k in $MyInvocation.BoundParameters.keys)
        {
            switch($MyInvocation.BoundParameters[$k].GetType().Name)
            {
                "SwitchParameter" {if($MyInvocation.BoundParameters[$k].IsPresent) { $argsString += "-$k " } }
                "String"          { $argsString += "-$k `"$($MyInvocation.BoundParameters[$k])`" " }
                "Int32"           { $argsString += "-$k $($MyInvocation.BoundParameters[$k]) " }
                "Boolean"         { $argsString += "-$k `$$($MyInvocation.BoundParameters[$k]) " }
            }
        }
        Start-Process -FilePath ”$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe” -ArgumentList "-File `"$($PSScriptRoot)\Install.ps1`" $($argsString)" -Wait -NoNewWindow
    }
    Catch {
        Throw “Failed to start 64-bit PowerShell”
    }
    Exit
}

# Copy Script into the Install Location
$null = New-Item -Path "$InstallLocation" -ItemType Directory -ErrorAction SilentlyContinue
Copy-Item "$PSScriptRoot\*" -Destination $InstallLocation -Exclude "Install.ps1" -Recurse -Force

# Create Registry Keys
New-Item "HKLM:\SOFTWARE\ZNerdInventoryCollector" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\ZNerdInventoryCollector" -Name MinutesBetweenRun -Value $RunInterval -PropertyType DWORD
New-ItemProperty -Path "HKLM:\SOFTWARE\ZNerdInventoryCollector" -Name LastExecution -Value "$([datetime]::new(0))" -PropertyType String

#region ConfigurationXML
# Create Base XML Document
[xml]$configuration = [System.Xml.XmlDocument]::new()
$null = $configuration.CreateXmlDeclaration("1.0","UTF-8",$null)
$parentNode = $configuration.CreateNode("element","InventoryCollection",$null)
$null = $configuration.AppendChild($parentNode)

# WMI
if($InWMI)
{
    $WMINode = $configuration.CreateNode("element","Source",$null)
    $WMIName = $configuration.CreateAttribute("Name")
    $null = $WMIName.Value = "WMI"
    $null = $WMINode.Attributes.Append($WMIName)
    $null = $configuration.DocumentElement.AppendChild($WMINode)
    
    #ConfigXML Path
    $Parameter = $configuration.CreateNode("element","Parameter",$null)
    $ParameterName = $configuration.CreateAttribute("Name")
    $null = $ParameterName.Value = "ConfigXML"
    $null = $Parameter.Attributes.Append($ParameterName)
    $ParameterName = $configuration.CreateAttribute("Value")
    $null = $ParameterName.Value = "$WMIConfigXML"
    $null = $Parameter.Attributes.Append($ParameterName)
    $null = $WMINode.AppendChild($Parameter)
}

# Add/Remove Programs
if($InAddRemovePrograms)
{
    $ARPNode = $configuration.CreateNode("element","Source",$null)
    $ARPName = $configuration.CreateAttribute("Name")
    $null = $ARPName.Value = "AddRemovePrograms"
    $null = $ARPNode.Attributes.Append($ARPName)
    $null = $configuration.DocumentElement.AppendChild($ARPNode)
}

# Log Analytics
if($OutLogAnalytics)
{
    $LANode = $configuration.CreateNode("element","Destination",$null)
    $LAName = $configuration.CreateAttribute("Name")
    $null = $LAName.Value = "LogAnalytics"
    $null = $LANode.Attributes.Append($LAName)
    $null = $configuration.DocumentElement.AppendChild($LANode)
        
    #Workspace ID
    $Parameter = $configuration.CreateNode("element","Parameter",$null)
    $ParameterName = $configuration.CreateAttribute("Name")
    $null = $ParameterName.Value = "LogAnalyticsWorkspaceId"
    $null = $Parameter.Attributes.Append($ParameterName)
    $ParameterName = $configuration.CreateAttribute("Value")
    $null = $ParameterName.Value = "$LogAnalyticsWorkspaceId"
    $null = $Parameter.Attributes.Append($ParameterName)
    $null = $LANode.AppendChild($Parameter)
    
    #Encryption
    $Parameter = $configuration.CreateNode("element","Parameter",$null)
    $ParameterName = $configuration.CreateAttribute("Name")
    $null = $ParameterName.Value = "EncryptWorkspacePrimaryKey"
    $null = $Parameter.Attributes.Append($ParameterName)
    $ParameterName = $configuration.CreateAttribute("Value")
    $null = $ParameterName.Value = "$([bool]$EncryptLogAnalyticsWorkspacePrimaryKey)"
    $null = $Parameter.Attributes.Append($ParameterName)
    $null = $LANode.AppendChild($Parameter)

    #Primary Key
    if($EncryptLogAnalyticsWorkspacePrimaryKey)
    {
        $ss = ConvertTo-SecureString -AsPlainText "$LogAnalyticsWorkspacePrimaryKey" -Force
        $LogAnalyticsWorkspacePrimaryKey = ConvertFrom-SecureString $ss
        $ss = $null
    }
    $Parameter = $configuration.CreateNode("element","Parameter",$null)
    $ParameterName = $configuration.CreateAttribute("Name")
    $null = $ParameterName.Value = "LogAnalyticsWorkspacePrimaryKey"
    $null = $Parameter.Attributes.Append($ParameterName)
    $ParameterName = $configuration.CreateAttribute("Value")
    $null = $ParameterName.Value = "$LogAnalyticsWorkspacePrimaryKey"
    $null = $Parameter.Attributes.Append($ParameterName)
    $null = $LANode.AppendChild($Parameter)
}

# Save XML Configuration File
$configuration.Save("$InstallLocation\Configuration.xml")
#endregion ConfigurationXML

# Create Scheduled Task
$stAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$InstallLocation\Invoke-InventoryCollector.ps1`" -ConfigXML `"$InstallLocation\Configuration.xml`""
$stTrigger = New-ScheduledTaskTrigger -Once -At 1am -RepetitionInterval (New-TimeSpan -Hours 1) -RandomDelay (New-TimeSpan -Minutes 30)
$stSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew
$null = Register-ScheduledTask -Action $stAction -Trigger $stTrigger -TaskName "GatherMachineInventory" -Description "Gathers configured machine inventory items and logs to the configured outputs" -RunLevel Highest -User "SYSTEM" -Settings $stSettings