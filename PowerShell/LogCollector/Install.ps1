#############################################
## Inventory Collector Install Script      ##
## Written By: Nathan Ziehnert (@theznerd) ##
#############################################
param(
    [switch]$InWMI,
    [string]$WMIConfigXML,

    [switch]$InAddRemovePrograms,

    [switch]$OutLogAnalytics,
    [string]$LogAnalyticsWorkspaceId,
    [string]$LogAnalyticsWorkspacePrimaryKey,
    [switch]$EncryptLogAnalyticsWorkspacePrimaryKey,

    [string]$InstallLocation = "$ENV:windir\InventoryCollector"
)

# Copy Necessary Files
$null = New-Item -Path "$InstallLocation" -ItemType Directory -ErrorAction SilentlyContinue
Copy-Item "$PSScriptRoot\*" -Destination $InstallLocation -Exclude "Install.ps1" -Recurse -Force

# Create Configuration XML
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

# Create Scheduled Task
$stAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$InstallLocation\Invoke-InventoryCollector.ps1`" -ConfigXML `"$InstallLocation\Configuration.xml`""
$stTrigger = New-ScheduledTaskTrigger -Once -At 1am -RepetitionInterval (New-TimeSpan -Hours 1) -RandomDelay (New-TimeSpan -Minutes 30)
$stSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew
$null = Register-ScheduledTask -Action $stAction -Trigger $stTrigger -TaskName "GatherMachineInventory" -Description "Gathers configured machine inventory items and logs to the configured outputs" -RunLevel Highest -User "SYSTEM" -Settings $stSettings