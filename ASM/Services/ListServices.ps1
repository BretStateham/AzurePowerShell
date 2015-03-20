# ==============================================================================
# ListServices.ps1
# ==============================================================================
# Simple script to list the Cloud Services (IaaS or PaaS) in your subscription
#
# This script shows a few different ways to list the services in your Azure 
# subscription using the Get-AzureService cmdlet. 
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


# First, let's just run the Get-AzureService cmdlet by itself...
Get-AzureService

# If you want to see the REST API calls that were made, you can 
# use the --Debug
Get-AzureService -Verbose


# You can retrieve just specific details if you want, for example
# in the following command we get just the ServiceName, Location & Url
Get-AzureService | select ServiceName, Location, Url

# The previous example listed the specific details veritically, (each on a 
# separate line).  Let's return them as columns in a table instead....
Get-AzureService | select ServiceName, Location, Url | Format-Table

# Next, let's clean up the table output by getting rid of the extra space
# between the columns and wrapping any long text...
Get-AzureService | select ServiceName, Location, Url | Format-Table -AutoSize -Wrap

