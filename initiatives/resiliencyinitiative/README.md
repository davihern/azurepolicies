# Resiliency Policy Initiative

Specify group of policies to ensure resiliency

## Try with PowerShell

````powershell
$policydefinitions = "resiliencyinitiative.definitions.json"
$policydefinitionsreplaced = "resiliencyinitiativereplaced.definitions.json"

$SubId = (Get-AzContext).Subscription.id
#$SubId = Get-AzSubscription -SubscriptionName 'Subscription01'

(Get-Content $policydefinitions).Replace("<<SUBSCRIPTION_ID>>",$SubId) | Set-Content $policydefinitionsreplaced

$policyset= New-AzPolicySetDefinition -Name "resiliencychecks" -DisplayName "Resiliency checks" -Metadata '{"category":"resiliency"}' -PolicyDefinition $policydefinitionsreplaced

Remove-Item $policydefinitionsreplaced

New-AzPolicyAssignment -PolicySetDefinition $policyset -Name "resiliencycheckassignment" -Scope "/subscriptions/$($SubId)"  
````

## retrieve audit alerts

````powershell

Start-AzPolicyComplianceScan

# Install from PowerShell Gallery via PowerShellGet
Install-Module -Name Az.PolicyInsights

# Import the downloaded module
Import-Module Az.PolicyInsights

Get-AzPolicyStateSummary -Top 1

# get only alerts from this specific policy set
Get-AzPolicyState -Filter "PolicySetDefinitionCategory eq 'resiliency'"

#summary table format
Get-AzPolicyState -Filter "PolicySetDefinitionCategory eq 'resiliency'" | Format-Table -AutoSize -Property PolicyDefinitionName,ResourceGroup,ResourceId -Wrap


````