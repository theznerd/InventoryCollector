###########################################
## Inventory Collector
## Written By: Nathan Ziehnert (@theznerd)
###########################################
param(
    [Parameter(mandatory=$true)]
    [string]$ConfigXML
)

# Load the Configuration XML
if($icXML -like "http*"){ [xml]$xml = (Invoke-WebRequest $ConfigXML).Content }
else{ [xml]$icXML = Get-Content $ConfigXML }

# Run Collection
$CollectedData = @()
foreach($source in $icXML.InventoryCollection.Source)
{
    $parameters = @{}
    foreach($p in $source.Parameter)
    {
        $parameters.Add($p.Name,$p.Value)
    }
    $CollectedData += (. "$PSScriptRoot\Extensions\Sources\$($source.Name).ps1" @parameters)
}

# Send Data To Destinations
foreach($cData in $CollectedData)
{
    foreach($destination in $icXML.InventoryCollection.Destination)
    {
        $parameters = @{
            jsonData = $cData
        }
        foreach($p in $destination.Parameter)
        {
            $parameters.Add($p.Name,$p.Value)
        }
        . "$PSScriptRoot\Extensions\Destinations\$($destination.Name).ps1" @parameters
    }
}
