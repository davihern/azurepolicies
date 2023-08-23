# Resiliency Policy Initiative

Specify group of policies to ensure resiliency

## Try with PowerShell

````powershell
$policydefinitions = "resiliencyinitiative.definitions.json"

$policyset= New-AzPolicySetDefinition -Name "resiliencychecks" -DisplayName "Resiliency checks" -Metadata '{"category":"resiliency"}' -PolicyDefinition $policydefinitions 
 
New-AzPolicyAssignment -PolicySetDefinition $policyset -Name <assignmentname> -Scope <scope>  
````

