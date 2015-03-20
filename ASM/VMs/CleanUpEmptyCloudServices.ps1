# ==============================================================================
# CleanUpEmptyCloudServices.ps1
# ==============================================================================
# This is a utility script to clean up empty cloud services that were
# created, but possibly never used by other scripts like the 
# SingleServiceMultipleVMs.ps1 script
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

Get-AzureService | 
    where ServiceName -like "vmsvc*" | 
    ForEach-Object {Remove-AzureService -ServiceName $_.ServiceName -Force}