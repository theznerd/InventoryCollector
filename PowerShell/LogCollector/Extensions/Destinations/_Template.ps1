###########################################
## Destination - DESTINATIONNAME
## Extension for Inventory Collector
## Written By: 
###########################################
param(
    [Parameter(mandatory=$true)]
    [string]$jsonData
    ## Add any additional parameters needed by the script
    ## such as API keys, etc.
)
# Load Newtonsoft JSON
$null = [Reflection.Assembly]::LoadFile("$PSScriptRoot\..\Libraries\Newtonsoft.Json.dll")
. "$PSScriptRoot\..\Libraries\ConvertFrom-JObject.ps1"
$jObject = [Newtonsoft.Json.JsonConvert]::DeserializeObject($jsonData)
$incomingData = ConvertFrom-JObject $jObject

###############################
## CUSTOM HANDLING CODE HERE ##
###############################
foreach($table in $incomingData.Data)
{
    # Process incoming data from the collection script
    # for ingestion into the destination
        # This could include adding columns to the rows 
        # (e.g. Comptuer Name, Date Collected, etc) or
        # removing special characters
    # Send the processed data to the destination
}