# ==============================================================================
# SingleServiceMultipleVMs.ps1
# ==============================================================================
# This script demonstrates how to create multiple VMs in a single cloud service
#
# This assumes you have used the:
#
# Get-AzurePublishSettingsFile & Import-AzurePublishSettingsFile scripts
#
# to setup your account and then used the:
#
# Select-AzureSubscription -SubscriptionName "<YourSubscriptionName>" -Current
# 
# to set the current subscription. 
#
# You can refer to the ../Accounts/LoginUsingCertificates.ps1 script for
# help
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Script variables
# ------------------------------------------------------------------------------

# Get a reference to the azure subscription that we are working against:
$subscription = (Get-AzureSubscription -Current);

# We'll use a YYMMDDHHmmssfff formatted timestamp (ts) to make names unique
$timeStamp = (Get-Date).ToString("yyMMddHHmmssfff");

# We'll create all of the resources in this script in the same Azure region.  
$location = "West US";

# For this example script, we'll use a dynamically named storage account
$storageAccountName = "vmvhds$($timeStamp)";

# similarly, we'll used a dynamic Cloud Service name:
$serviceName = "vmsvc$($timestamp)";

# We'll be creating multiple VMs, but we'll need a base name for them
$vmBaseName = "vm";

# We'll create VMs using the size:
$vmSize = "ExtraSmall";

# We'll use the latest image int the image family:
$imageFamily = "Visual Studio Community 2013 Update 4 on Windows Server 2012 R2";

# We'll pick a base RDP port of the VMs to use
$rdpBasePort = 33890;

# And a base HTTP port
$httpBasePort = 8000;

# We need the administrator user name and password for the VMs
$adminUser = "adminuser";
$adminPwd  = "P@ss!234";

# How many VMs will we create
$numVMs = 2;


# ------------------------------------------------------------------------------
# Create the storage account and set it as the current storage account
# ------------------------------------------------------------------------------


# Test to see if a storage account with that name already exists.  If it does abort.
if((Test-AzureName -Storage -Name $storageAccountName -ErrorAction SilentlyContinue)) {
    Write-Warning "A storage account named $storageAccountName already exists.";
    Write-Warning "Aborting the script execution, run it again to get a new storage account name.";
    Return;
}


#Create the storage account
Write-Host "The Virtual Machine Hard Drives (VHDs) will be stored in: $($storageAccountName)";
New-AzureStorageAccount -StorageAccountName $storageAccountName `
                        -Location $location `
                        -Type Standard_GRS `
                        -Label $storageAccountName `
                        -Description "Dynamically created storage account.  Used to store VM VHDs";

# And set it as the current storage account for the current subscription
# Don't skip this step.  It sets the location that VM VHDs will be stored.
Set-AzureSubscription -SubscriptionName $subscription.SubscriptionName `
                      -CurrentStorageAccountName $storageAccountName;


# ------------------------------------------------------------------------------
# Create the Cloud Service
# ------------------------------------------------------------------------------

# Test to see if a Cloud Service with that name already exists.  If it does abort.
if((Test-AzureName -Service -Name $serviceName -ErrorAction SilentlyContinue)) {
    Write-Warning "A Cloud Service named $serviceName already exists.";
    Write-Warning "Aborting the script execution, run it again to get a new Service name.";
    Return;
}


#Create the Service
Write-Host "`rCreating the Cloud Service: $($storageAccountName)";
New-AzureService -ServiceName $serviceName `
                 -Location $location `
                 -Label $location `
                 -Description "Dynamically created Cloud Service";




# ------------------------------------------------------------------------------
# Create the VM configs
# ------------------------------------------------------------------------------

#First determine the name of the latest image in the specified image family:
$imageName = (Get-AzureVMImage | 
             where { $_.ImageFamily -eq $imageFamily } | 
             Select -first 1 | 
             Select ImageName).ImageName



Write-Host "`r`nVMs will be created using the image:`r`n$($imageName)";

#This will be the collection of VM Configurations to create
$vmConfigs = @();

#Create the infividual VMConfigs
for($vm = 1; $vm -le $numVMs; $vm++) {

  
  $vmName = "$($vmBaseName)$([System.String]::Format("{0:000}",$vm))"; 
  $rdpPort = $rdpBasePort + $vm
  $httpPort = $httpBasePort + $vm

  $vmConfig = New-AzureVMConfig -ImageName $imageName -InstanceSize $vmSize -Name $vmName -Label $vmName | 
              Add-AzureProvisioningConfig -Windows -AdminUsername $adminUser -Password $adminPwd | 
              Add-AzureEndpoint -LocalPort 3389 -Name 'RDP' -protocol tcp -PublicPort $rdpPort | 
              Add-AzureEndpoint -LocalPort 80 -Name 'HTTP' -protocol tcp -PublicPort $httpPort

  $vmConfigs += ,$vmConfig;

}

#Create the VMs...
New-AzureVM -ServiceName $serviceName -VMs $vmConfigs




