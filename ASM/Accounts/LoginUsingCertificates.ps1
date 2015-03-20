# ==============================================================================
# LoginUsingCertificates.ps1
# ==============================================================================
# This script shows you how to login to your Azure Account using a certificate
# that is downloaded from the Azure Portal.
#
# It uses the Get-AzurePublishSettingsFile file to download the account info
# and subscription
#
# Then it uses the Import-AzurePulishSettingsFile to import the info and 
# certificate into your Azure PowerShell configuration.
#
# ==============================================================================

# This is a utility function used to browse to the publishsettings file
# I stole it from http://blogs.technet.com/b/heyscriptingguy/archive/2009/09/01/hey-scripting-guy-september-1.aspx
Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "Publish Settings (*.publishsettings)| *.publishsettings"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

# First, let's download (get) the Azure Publish Settings file.  The user will be 
# prompted to login to the desired azure account and then save the *.publishsettings
# to a location on disk.  Pay attention to the path of the file you downloaded.  
# You'll need it for the Import-AzurePublishSettingsFile cmdlet.

Get-AzurePublishSettingsFile 

Write-Host "--------------------------------------------------------------------------------";
Write-Host "Use the browser to download your *.publishsettings file"
Write-Host "Make sure to pay attention to the path where you saved it."
Write-Host -NoNewLine "When you have saved the file, "
Pause
Write-Host "--------------------------------------------------------------------------------";


#Now, browse to point to the file you just downloaded, so you can import it...
$settingsFile = Get-FileName -initialDirectory "c:\azcert"

Write-Host "--------------------------------------------------------------------------------";
Write-Host "Importing subscription from ""$settingsFile""...";
Write-Host "--------------------------------------------------------------------------------";

#Finally, import the account & subscription info and certificate...
Import-AzurePublishSettingsFile -PublishSettingsFile $settingsFile

Write-Host "--------------------------------------------------------------------------------";
Write-Host "Here are the Azure Accounts you have imported..."
Write-Host "--------------------------------------------------------------------------------";

#Now, you can run the "Get-AzureAccount" to list the Azure Accounts you can work with:
Get-AzureAccount | Format-Table

Write-Host "--------------------------------------------------------------------------------";
Write-Host "And the Azure Subscripitions on those accounts..."
Write-Host "--------------------------------------------------------------------------------";

#And the #Get-AzureSubscription to list the available subscriptions:
Get-AzureSubscription

Write-Host "--------------------------------------------------------------------------------";
Write-Host "The default subscription (used by all powershell sessions by default) is..."
Write-Host "--------------------------------------------------------------------------------";

#Use the Get-AzureSubscription -Default to see default subscription
Get-AzureSubscription -Default

Write-Host "--------------------------------------------------------------------------------";
Write-Host "The current subscription (used in a single session to override the default) is..."
Write-Host "--------------------------------------------------------------------------------";

#Use the Get-AzureSubscription -Default to see default subscription
Get-AzureSubscription -Current

Write-Host "--------------------------------------------------------------------------------";
Write-Host "Read the commented code to see how to set the default & current subscriptions...";
Write-Host "--------------------------------------------------------------------------------";


# You can use the Select-AzureSubscription cmdlet to set the new Default and Current subscriptions
#
# The "default" subscription is the one that will be used by all subsequent powershell sessions
# by default
#
# The "current" subscription is a way in a single session to override the default subscription
# and point to a specific, alternate subscription.   If no "current" is set, it falls back to the 
# default.
#
# Setting the default subscription:
#
#   Select-AzureSubscription -SubscriptionName "<Desired Default Subscription Name>" -Default
#
# Setting the current subscription:
#
#  # Select-AzureSubscription -SubscriptionName "<Desired Current Subscription Name>" -Current

Write-Host "--------------------------------------------------------------------------------";
Write-Host "Read the commented code to see how to remove a subscription or account...";
Write-Host "--------------------------------------------------------------------------------";

# You can remove an Azure Subscription from your powershell configuration using the 
# Remove-AzureSubscription cmdlet. This just removes it from your powershell config, it does
# not affect the actual subscription in Azure.
#
# If the subscription is the only subscription associated with an Azure account, the account
# will be removed as well
#
# Removing a subscription by id:
#
#  Remove-AzureSubscription -SubscriptionId "<your subscription id here> -Force"
#
# Removing a subscription by name:
#
#  Remove-AzureSubscription -SubscriptionName "<your subscription name here> -Force"
#
# You can also remove an Azure Account and all it's subscriptions using the 
# Remove-AzureAccount cmdlet
#
# The cmdlet takes a "-Name" parameter that actually maps the the "ID" column value
# returned by the Get-AzureAccount cmdlet.  The ID will be the account id if it was
# added from a *.publishsettings file via the Import-AzurePublishSettingsFile cmdlet.
# The ID will be the microsoft account name (name@outlook.com, etc.) of if the account
# was added via the Add-AzureAccount cmdlet.
#
# Remove-AzureAccount -Name "<Account ID or login name>" -Force



