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
    [string]$DateCollected = (Get-Date -Format "yyyyMMddHHmmss")
    [string]$Source = "WMI"
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
# Load the Configuration XML
if($xml -like "http*"){ [xml]$xml = (Invoke-WebRequest $ConfigXML).Content }
else{ [xml]$xml = Get-Content $ConfigXML }

# Process Data
foreach($namespace in $xml.WMIConfiguration.Namespace)
{
    $namespaceDataName = $namespace.Path.Replace('\','-')
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
        $output.Data += $t
    }
}
[Newtonsoft.Json.JsonConvert]::SerializeObject($output)