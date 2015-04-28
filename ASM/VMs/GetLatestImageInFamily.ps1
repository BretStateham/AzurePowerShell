# ==============================================================================
# GetLatestImageInFamily.ps1
# ==============================================================================
# This script demonstrates how to get the latest virtual machine image given the
# image family.
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

# FYI, Here is how to see a list of all of the Image Families:
# Get-AzureVMImage | select ImageFamily | sort-object -Property ImageFamily -Unique

# We'll find the latest image int the image family:
$imageFamily = "Windows Server 2012 R2 Datacenter";


#Determine the name of the latest image in the specified image family:
$imageName = (Get-AzureVMImage | 
             where { $_.ImageFamily -eq $imageFamily } | 
             Select -first 1 | 
             Select ImageName).ImageName


Write-Host "`r`nImage Family:`r`n$($imageFamily)";
Write-Host "`r`nImage Name:`r`n$($imageName)";

