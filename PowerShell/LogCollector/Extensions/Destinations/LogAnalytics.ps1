###########################################
## Log Analytics Extension
## Extension for Inventory Collector
## Written By: Nathan Ziehnert (@theznerd)
###########################################
param(
    [Parameter(mandatory=$true)]
    [string]$jsonData,
    [Parameter(mandatory=$true)]
    [string]$LogAnalyticsWorkspaceId,
    [Parameter(Mandatory=$true)]
    [string]$LogAnalyticsWorkspacePrimaryKey,
    [Parameter(Mandatory=$false)]
    [string]$EncryptWorkspacePrimaryKey
)
# Load Newtonsoft JSON
$null = [Reflection.Assembly]::LoadFile("$PSScriptRoot\..\Libraries\Newtonsoft.Json.dll")
. "$PSScriptRoot\..\Libraries\ConvertFrom-JObject.ps1"
$jObject = [Newtonsoft.Json.JsonConvert]::DeserializeObject($jsonData)
$incomingData = ConvertFrom-JObject $jObject

###############################
## CUSTOM HANDLING CODE HERE ##
###############################
if($EncryptWorkspacePrimaryKey -eq "true")
{
    $SecureString = ConvertTo-SecureString -String $LogAnalyticsWorkspacePrimaryKey
    $LogAnalyticsWorkspacePrimaryKey = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecureString))
}

. "$PSScriptRoot\LogAnalytics-Functions.ps1"

foreach($table in $incomingData.Data)
{
    $logType = ("$($incomingData.Source)-$($table.TableName)").Replace("-","_")
    $table.Remove("TableName")
    foreach($row in $table.Rows)
    {
        [hashtable]$tempHashTable = @{}
        foreach($rd in $row.RowData[0].Keys)
        {
            $tempHashTable.Add($rd,$row.RowData[0][$rd])
        }
        $tempHashTable.Add("ReportedComputerName","$($incomingData.ComputerName)")
        $tempHashTable.Add("ReportedDomain","$($incomingData.ComputerDomain)")
        $tempHashTable.Add("DateCollected","$($incomingData.DateCollected)")
        $row.RowData = $tempHashTable
    }
    $laContent = [Newtonsoft.Json.JsonConvert]::SerializeObject($table.Rows)
    $laContent = $laContent -replace "{`"RowData`":(.*?)}},",'$1},' -replace '}}]$','}]' -replace "{`"RowData`":",""
    Post-LogAnalyticsData -LogAnalyticsWorkspaceId $LogAnalyticsWorkspaceId -LogAnalyticsWorkspacePrimaryKey $LogAnalyticsWorkspacePrimaryKey -body $laContent -logType $logType
}