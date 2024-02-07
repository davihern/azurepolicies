# Resiliency Policy Initiative

Specify group of policies to ensure resiliency


Before executing these policies in Powershell ensure that you are in the correct Azure subscription:

````
Connect-AzAccount
Set-AzContext -Subscription "<<SUBSCRIPTION_ID>>"
````

## Try with PowerShell

````powershell
#register custom policies

New-AzPolicyDefinition -Name "appservice64bits" -Policy './policies/appservice64bits/appservice64bits.json'
New-AzPolicyDefinition -Name "appservicealwayson" -Policy './policies/appservicealwayson/appservicealwayson.json'
New-AzPolicyDefinition -Name "appservicearrondisabled" -Policy './policies/appservicearrondisabled/appservicearrondisabled.json'
New-AzPolicyDefinition -Name "appservicehealthcheck" -Policy './policies/appservicehealthcheck/appservicehealthcheck.json'



# create a policy set (aka initiatives)
$policydefinitions = "./initiatives/resiliencyinitiative/resiliencyinitiative.definitions.json"
$policydefinitionsreplaced = "./initiatives/resiliencyinitiative/resiliencyinitiativereplaced.definitions.json"

$SubId = (Get-AzContext).Subscription.id
#$SubId = Get-AzSubscription -SubscriptionName 'Subscription01'

(Get-Content $policydefinitions).Replace("<<SUBSCRIPTION_ID>>",$SubId) | Set-Content $policydefinitionsreplaced

$policyset= New-AzPolicySetDefinition -Name "resiliencychecks" -DisplayName "Resiliency checks" -Metadata '{"category":"resiliency"}' -PolicyDefinition $policydefinitionsreplaced

#remove the generated file, to keep code clean and to ensure script is idempotent
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