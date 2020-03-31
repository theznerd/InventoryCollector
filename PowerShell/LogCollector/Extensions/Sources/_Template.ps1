###########################################
## Source - SOURCENAME
## Extension for Inventory Collector
## Written By: 
###########################################
param(
    # Add any necessary parameters for collection. For example
    # a configuration file.
)
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

#Collect Azure AD Tenant Information
$dsregCmd = (dsregcmd /status) | ConvertFrom-String
if(($dsregCmd | Where {$_.P2 -eq "AzureADJoined"}).P4 -eq "YES")
{
    $output.ComputerAADDomain = ($dsregCmd | Where {$_.P2 -eq "TenantName"}).P4
    $output.ComputerAADTenantId = ($dsregCmd | Where {$_.P2 -eq "TenantId"}).P4
}

###############################
## CUSTOM HANDLING CODE HERE ##
###############################

## For your custom handling code, you will need
## to organize your data into a row/table format.
## You can have multiple tables as part of the
## SourceOutput class (e.g. for WMI a new table
## is created for each WMI class being queried).

## Create a table (or tables)
   ## Add rows to the table
      ## Add data to the rows in a hashtable format
      ## e.g. $r.RowData = $resultHash
## Ensure that all tables are added to the $output.Data property

# Output the data
[Newtonsoft.Json.JsonConvert]::SerializeObject($output)