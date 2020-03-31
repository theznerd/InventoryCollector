Unregister-ScheduledTask -TaskName "GatherMachineInventory" -Confirm:$false
Remove-Item $PSScriptRoot -Force -Confirm:$false -Recurse