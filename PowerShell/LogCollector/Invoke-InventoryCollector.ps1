<#
.DESCRIPTION
The invocation script to collect data and then export data to the configured
sources based on the Configuration XML file.

.PARAMETER ConfigXML
The path to the configuration XML generated by the installer or a custom
configuration XML path.

.NOTES
Written By: Nathan Ziehnert
Twitter: @theznerd
Blog: https://z-nerd.com

.LINK
https://github.com/theznerd/InventoryCollector
#>
param(
    [Parameter(mandatory=$true)]
    [string]$ConfigXML
)

### Validate Inventory Needs Collection
#Configured Inventory Cycle
$minutesBetweenRuntime = (Get-ItemProperty HKLM:\SOFTWARE\ZNerdInventoryCollector).MinutesBetweenRun

#Last Execution Time
try{
    $lastRuntime = [datetime]::Parse((Get-ItemProperty HKLM:\SOFTWARE\ZNerdInventoryCollector).LastExecution)
}
catch{
    $lastRuntime = [datetime]::new(0)
}

$currentTime = [datetime]::Now

# Exit if the inventory has run within the configured window already
if(($currentTime - $lastRuntime).TotalMinutes -le $minutesBetweenRuntime)
{
    Exit
}


### Load the Configuration XML
if($icXML -like "http*"){ [xml]$xml = (Invoke-WebRequest $ConfigXML -UseBasicParsing).Content }
else{ [xml]$icXML = Get-Content $ConfigXML }


### Collect Data from Sources
$CollectedData = @()
foreach($source in $icXML.InventoryCollection.Source)
{
    $parameters = @{}
    foreach($p in $source.Parameter)
    {
        $parameters.Add($p.Name,$p.Value) # add parameters necessary to the source collection plugin
    }
    $CollectedData += (. "$PSScriptRoot\Extensions\Sources\$($source.Name).ps1" @parameters) # collect data from source collection plugin
}

### Export Data to Destinations
foreach($cData in $CollectedData)
{
    foreach($destination in $icXML.InventoryCollection.Destination)
    {
        $parameters = @{
            jsonData = $cData
        }
        foreach($p in $destination.Parameter)
        {
            $parameters.Add($p.Name,$p.Value) # add parameters necessary to the destination plugin
        }
        . "$PSScriptRoot\Extensions\Destinations\$($destination.Name).ps1" @parameters # send data to destination
    }
}

#Update Last Run Time
Set-ItemProperty HKLM:\SOFTWARE\ZNerdInventoryCollector -Name LastExecution -Value $([datetime]::Now)