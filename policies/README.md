# Audit TLS 1.2 on Storage accounts

This policy audits Storage Accounts to check on TLS version


## Try with PowerShell

````powershell
$definition = New-AzPolicyDefinition -Name "storageminTLS" -Policy 'storageminTLS.json'

````

