terraform destroy -auto-approve

# reverting the use of the remote backend 
$terraformFilePath = "$PSScriptRoot\main.tf"
$original = 'backend "azurerm" {}'
$replacement = '# backend "azurerm" {}'
(Get-Content $terraformFilePath) -replace $original, $replacement  | Set-Content $terraformFilePath
terraform init 
(Get-Content $terraformFilePath) -replace $replacement, $original | Set-Content $terraformFilePath

# we remove these .tfvars file because the RunLab.ps1 (via SetupAzureEnvironment.ps1) set them up dynamically and them can change from one run to another
Remove-Item $PSScriptRoot\*.tfvars 

$tfStorageRG = "tf-storage-rg"
$servicePrincipalBaseName = "tf-sp"

$tfsaName = az storage account list `
  --resource-group $tfStorageRG `
  --query [].name `
  --output tsv # tsv = Tab-separated values, with no keys

az storage account delete `
  --name $tfsaName `
  --yes

az group delete `
  --name $tfStorageRG `
  --yes

$servicePrincipalId = az ad sp list `
  --filter "startswith(displayName, '$servicePrincipalBaseName')" `
  --query "[].objectId" `
  --output tsv
if($servicePrincipalId){ 
  az ad sp delete --id $servicePrincipalId
}