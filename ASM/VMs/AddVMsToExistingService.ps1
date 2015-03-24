# ==============================================================================
# AddVMsToExistingServiceAndStorage.ps1
# ==============================================================================
# This script demonstrates how to create add VMs to an existing Cloud service
# and storage account
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

# We'll create all of the resources in this script in the same Azure region.  
$location = "West US";

# For this example script, we'll use the name of an existing storage account
$storageAccountName = "vmvhds150320135456934";

# similarly, we'll used an existing Cloud Service name:
$serviceName = "vmsvc150320135456934";

# We'll be creating multiple VMs, but we'll need a base name for them
$vmBaseName = "vmx";

# We'll create VMs using the size:
$vmSize = "ExtraSmall";

# We'll use the latest image int the image family:
$imageFamily = "Visual Studio Community 2013 Update 4 on Windows Server 2012 R2";

# We'll pick a base RDP port of the VMs to use
$rdpBasePort = 33990;

# And a base HTTP port
$httpBasePort = 8100;

# We need the administrator user name and password for the VMs
$adminUser = "adminuser";
$adminPwd  = "P@ss!234";

# How many VMs will we create
$numVMs = 2;


# ------------------------------------------------------------------------------
# Ensure the storage account and set it as the current storage account
# ------------------------------------------------------------------------------


# Verify that a storage account with that name already exists.  If it doesn't abort.
if(!(Test-AzureName -Storage -Name $storageAccountName -ErrorAction SilentlyContinue)) {
    Write-Warning "A storage account named $storageAccountName does not exist.";
    Write-Warning "Aborting the script execution, run it again with the correct storage account name.";
    Return;
}


# And set it as the current storage account for the current subscription
# Don't skip this step.  It sets the location that VM VHDs will be stored.
Set-AzureSubscription -SubscriptionName $subscription.SubscriptionName `
                      -CurrentStorageAccountName $storageAccountName;


# ------------------------------------------------------------------------------
# Ensure the Cloud Service
# ------------------------------------------------------------------------------

# Verify that a Cloud Service with that name already exists.  If it doesn't abort.
if(!(Test-AzureName -Service -Name $serviceName -ErrorAction SilentlyContinue)) {
    Write-Warning "A Cloud Service named $serviceName does not exist.";
    Write-Warning "Aborting the script execution, run it again with the correct Service name.";
    Return;
}


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




