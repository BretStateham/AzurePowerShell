# ==============================================================================
# CleanUpEmptyVMVHDsStorageAccounts.ps1
# ==============================================================================
# This is a utility script to clean up empty vmvhds* storage accounts that were
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

Get-AzureStorageAccount | 
    where StorageAccountName -like "vmvhds*" | 
    ForEach-Object {Remove-AzureStorageAccount -StorageAccountName $_.StorageAccountName}