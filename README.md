# Resiliency Policy Initiative

Specify group of policies to ensure resiliency

## Try with PowerShell

````powershell
#register custom policies

$definition = New-AzPolicyDefinition -Name "storageminTLS" -Policy "./policies/storageminTLS/storageminTLS.json"
$definition = New-AzPolicyDefinition -Name "appservice64bits" -Policy './policies/appservice64bits/appservice64bits.json'
$definition = New-AzPolicyDefinition -Name "appservicealwayson" -Policy './policies/appservicealwayson/appservicealwayson.json'
$definition = New-AzPolicyDefinition -Name "appservicearrondisabled" -Policy './policies/appservicearrondisabled/appservicearrondisabled.json'



# create a policy set (aka initiatives)
$policydefinitions = "./initiatives/resiliencyinitiative/resiliencyinitiative.definitions.json"
$policydefinitionsreplaced = "./initiatives/resiliencyinitiative/resiliencyinitiativereplaced.definitions.json"

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


## Reference

Sample repo to store some azure policies

CI/CD: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-as-code

Reference for Policy json: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure

Reference for initiative json schema: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/initiative-definition-structure 

GitHub repo with samples: https://github.com/Azure/azure-policy/tree/master/.github