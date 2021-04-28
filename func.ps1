using namespace System.Net
using namespace Az.Accounts

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."


$iops = $Request.Body.IOPS
$diskName = $Request.Body.DiskName
$resourceGroupName = $Request.Body.ResourceGroupName
if (($iops) -and ($diskName) -and ($resourceGroupName))
{
    Write-Host "Connecting to Azure"
    Connect-AzAccount -Identity
    $Context = Get-AzContext
    $Sub = $Context | ConvertTo-Json
    Write-Host "Updating disk IOPS"
    $diskupdateconfig = New-AzDiskUpdateConfig -DiskIOPSReadWrite $iops
    Update-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName -DiskUpdate $diskupdateconfig
    Write-Host "Successfully Updated disk IOPS"
    $body = "Successfully updated the IOPS value to [$iops] for Disk [$diskName] in Resource Group [$resourceGroupName]."
}
else
{
    $body = "Please pass value for ResourceGroupName, DiskName and IOPS"
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
