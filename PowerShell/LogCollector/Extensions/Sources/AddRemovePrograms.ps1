###########################################
## Source - Add/Remove Programs
## Extension for Inventory Collector
## Written By: Nathan Ziehnert (@theznerd)
###########################################
# Load Newtonsoft JSON
$null = [Reflection.Assembly]::LoadFile("$PSScriptRoot\..\Libraries\Newtonsoft.Json.dll")

###############################################
## Class Definitions                         ##
## Only Change $Source in SourceOutput Class ##
###############################################
class SourceOutput {
    [string]$ComputerName = $env:COMPUTERNAME
    [string]$ComputerDomain = (Get-CimInstance -ClassName Win32_ComputerSystem -Property Domain).Domain
    [string]$ComputerAADDomain
    [string]$ComputerAADTenantId
    [string]$DateCollected = (Get-Date -Format "yyyyMMddHHmmss")
    [string]$Source = "REG"
    [Table[]]$Data
}

class Table {
    [string]$TableName
    [Row[]]$Rows
}

class Row {
    [Object[]]$RowData
}

#Prep Output
$output = [SourceOutput]::new()

$dsregCmd = (dsregcmd /status) | ConvertFrom-String
if(($dsregCmd | Where {$_.P2 -eq "AzureADJoined"}).P4 -eq "YES")
{
    $output.ComputerAADDomain = ($dsregCmd | Where {$_.P2 -eq "TenantName"}).P4
    $output.ComputerAADTenantId = ($dsregCmd | Where {$_.P2 -eq "TenantId"}).P4
}

###############################
## CUSTOM HANDLING CODE HERE ##
###############################
$t = [Table]::new()
$t.TableName = "AddRemovePrograms"
[regex]$guidRegex = '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$'

# Collect all registry entries in the Uninstall keys for Add/Remove Programs
$Architecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
if($Architecture -eq "64-bit")
{
    $32Bit = Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
}
$64Bit = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

# Collect info from the native SOFTWARE hive
foreach($program in $64Bit)
{
    $r = [Row]::new()
    $rowData = @{
        Architecture = $Architecture
        DisplayName = $program.GetValue("DisplayName")
        InstalDate = $program.GetValue("InstallDate")
        DisplayVersion = $program.GetValue("DisplayVersion")
        Publisher = $program.GetValue("Publisher")
    }

    # Because product IDs can be GUIDs or strings, prepend "GUID:" to GUID
    # results so that they aren't handled differently by Log Analytics
    if($program.PSChildName -match $guidRegex)
    {
        $rowData.Add("ProductID","GUID:$($program.PSChildName)")
    }else{
        $rowData.Add("ProductID",$program.PSChildName)
    }

    $r.RowData = $rowData
    $t.Rows += $r
}

# Collect info from the WindowsOnWindows SOFTWARE hive (32-bit software on 64-bit systems)
foreach($program in $32Bit)
{
    $r = [Row]::new()
    $rowData = @{
        Architecture = "32-Bit"
        DisplayName = $program.GetValue("DisplayName")
        InstalDate = $program.GetValue("InstallDate")
        DisplayVersion = $program.GetValue("DisplayVersion")
        Publisher = $program.GetValue("Publisher")
    }
    
    # Because product IDs can be GUIDs or strings, prepend "GUID:" to GUID
    # results so that they aren't handled differently by Log Analytics
    if($program.PSChildName -match $guidRegex)
    {
        $rowData.Add("ProductID","GUID:$($program.PSChildName)")
    }else{
        $rowData.Add("ProductID",$program.PSChildName)
    }
    $r.RowData = $rowData
    $t.Rows += $r
}
$output.Data = $t

# Output the data
[Newtonsoft.Json.JsonConvert]::SerializeObject($output)