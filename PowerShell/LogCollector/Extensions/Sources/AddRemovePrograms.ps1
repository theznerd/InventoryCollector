###########################################
## Add/Remove Programs Data Source
## Extension for Inventory Collector
## Written By: Nathan Ziehnert (@theznerd)
###########################################
# Load Newtonsoft JSON
$null = [Reflection.Assembly]::LoadFile("$PSScriptRoot\..\Libraries\Newtonsoft.Json.dll")

#########################################
## Class Definitions                   ##
## Only Change $Source in SourceOutput ##
#########################################
class SourceOutput {
    [string]$ComputerName = $env:COMPUTERNAME
    [string]$ComputerDomain = (Get-CimInstance -ClassName Win32_ComputerSystem -Property Domain).Domain
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

###############################
## CUSTOM HANDLING CODE HERE ##
###############################
$t = [Table]::new()
$t.TableName = "AddRemovePrograms"
[regex]$guidRegex = '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$'

$Architecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
if($Architecture -eq "64-bit")
{
    $32Bit = Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
}
$64Bit = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

foreach($program in $64Bit)
{
    $r = [Row]::new()
    $rowData = @{
        Architecture = "64-Bit"
        DisplayName = $program.GetValue("DisplayName")
        InstalDate = $program.GetValue("InstallDate")
        DisplayVersion = $program.GetValue("DisplayVersion")
        Publisher = $program.GetValue("Publisher")
    }
    if($program.PSChildName -match $guidRegex)
    {
        $rowData.Add("ProductID","GUID:$($program.PSChildName)")
    }else{
        $rowData.Add("ProductID",$program.PSChildName)
    }

    $r.RowData = $rowData
    $t.Rows += $r
}
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
[Newtonsoft.Json.JsonConvert]::SerializeObject($output)