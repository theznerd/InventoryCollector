###########################################
## WMI Data Source
## Extension for Inventory Collector
## Written By: Nathan Ziehnert (@theznerd)
###########################################
param(
    [Parameter(mandatory=$true)]
    [string]$ConfigXML
)
# Load Newtonsoft JSON
$null = [Reflection.Assembly]::LoadFile("$PSScriptRoot\..\Libraries\Newtonsoft.Json.dll")

#########################################
## Class Definitions                   ##
## Only Change $Source in SourceOutput ##
#########################################
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
# Load the Configuration XML
if($xml -like "http*"){ [xml]$xml = (Invoke-WebRequest $ConfigXML -UseBasicParsing).Content }
else{ [xml]$xml = Get-Content $ConfigXML }

# Process Data
foreach($namespace in $xml.WMIConfiguration.Namespace)
{
    # Most systems don't accept \ as a valid character, just change it now
    $namespaceDataName = $namespace.Path.Replace('\','-')

    # Look at each configured class in the namespace and create a new table with the data
    foreach($class in $namespace.Class)
    {
        $t = [Table]::new()
        $t.TableName = "$namespaceDataName-$($class.Name)"
        
        $properties = $class.Property.Name
        $classResult = Get-CimInstance -Namespace $namespace.Path -ClassName $class.Name -Property $properties | Select-Object $properties
        
        foreach($result in $classResult)
        {
            $resultHT = @{}
            foreach($p in $result.psobject.Properties)
            {
                # If data is an integer, then export it as is, otherwise export as a string
                if($null -ne $p.Value -and ($p.Value.GetType().Name -eq "Int32" -or $p.Value.GetType().Name -eq "UInt32"))
                {
                    $resultHT[$p.Name] = $p.Value
                }
                else
                {
                    $resultHT[$p.Name] = [string]$p.Value
                }
            }
            $r = [Row]::new()
            $r.RowData = $resultHT
            $t.Rows += $r
        }
        # Add the WMI class to the list of tables being output by the script
        $output.Data += $t
    }
}

# Output the data
[Newtonsoft.Json.JsonConvert]::SerializeObject($output)