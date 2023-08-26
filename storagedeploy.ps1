$rg = 'arm-introduction-task'
$adminUsername = 'ja-azVM' # You can customize this username
$adminPassword = 'juna-azVM#!^@' #Read-Host -Prompt "Enter the administrator password" -AsSecureString
$dnsLabelPrefix = 'mydns' # Customize the DNS label prefix
New-AzResourceGroup -Name $rg -Location westeurope

# Deploy the storage account using an ARM template
New-AzResourceGroupDeployment `
    -Name 'sa-deploy' `
    -ResourceGroupName $rg `
    -TemplateFile 'azureSATemplate.json'

# Deploy the virtual machine using an ARM template

# This creates a new hashtable variable named '$vmDeploymentParams'.
# This hashtable is used to store parameter values that will be passed to an 
# Azure Resource Manager (ARM) template during deployment.
# Each parameter is represented by a key-value pair within the hashtable.
$vmDeploymentParams = @{
    'adminUsername' = $adminUsername
    'adminPassword' = $adminPassword
    'dnsLabelPrefix' = $dnsLabelPrefix
}

New-AzResourceGroupDeployment `
    -Name 'vm-deploy' `
    -ResourceGroupName $rg `
    -TemplateFile 'azureVMTemplate.json' `
    -TemplateParameterObject $vmDeploymentParams
