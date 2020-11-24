param(
  [Parameter(Mandatory)]
  [string] $Location, # ex : "francecentral"
  [bool] $ServicePrincipal
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Write-Verbose "Loading external scripts"
. "$PSScriptRoot\AskUserChoice.ps1"
Write-Verbose "Loaded external scripts"

Write-Verbose "Logging to Azure"
az account show 2> $Null
if(! $?){
  az login 1> $Null
}
elseif(!(KeepThisAccount)){
  az logout
  az login 1> $Null
}
Write-Verbose "Logged to Azure"

Write-Verbose "Checking the validity of the location provided"
$AvailableLocations = az account list-locations `
  --query "[].{Name: name}" `
  --output tsv  # tsv = Tab-separated values, with no keys

if(! $AvailableLocations.Contains($Location)){
  Write-Host "Invalid Azure DC location provided"
  exit 1
}
Write-Verbose "The location provided is valid"
# we have to put this in the terraform.tfvars script for terraform to know this value
Write-Output "resource_group_location = `"$Location`"" | Tee-Object $PSScriptRoot\terraform.tfvars

$uniqueId = Get-Random -Min 1000 -Max 9999 # 1390456
$tfStorageRG = "tf-storage-rg"
$tfStatefileName = "terraform.tfstate"
# we have to put this in the backend.tfvars script for terraform to know this value
Write-Output "resource_group_name = `"$tfStorageRG`""  | Tee-Object $PSScriptRoot\backend.tfvars

az group create `
  --location $Location `
  --name $tfStorageRG

# create Storage account if not exists or reuse the existing one
$tfsaName = az storage account list `
    --resource-group $tfStorageRG `
    --query [].name `
    --output tsv # tsv = Tab-separated values, with no keys

if(! $tfsaName){
  az storage account create `
    --name tfsa$uniqueId `
    --resource-group $tfStorageRG `
    --sku Standard_LRS

  $tfsaName = az storage account list `
    --resource-group $tfStorageRG `
    --query [].name `
    --output tsv # tsv = Tab-separated values, with no keys
}

# we have to put this in the backend.tfvars script for terraform to know this value
Write-Output "storage_account_name = `"$tfsaName`"" | Tee-Object -Append $PSScriptRoot\backend.tfvars

az storage container create `
  --account-name $tfsaName `
  --name tfstate

$tfcontainerName = az storage container list `
  --account-name $tfsaName `
  --query [].name `
  --output tsv # tsv = Tab-separated values, with no keys
# we have to put this in the backend.tfvars script for terraform to know this value
Write-Output "container_name = `"$tfcontainerName`""  | Tee-Object -Append $PSScriptRoot\backend.tfvars
Write-Output "key = `"$tfStatefileName`""  | Tee-Object -Append $PSScriptRoot\backend.tfvars

if($ServicePrincipal){
  $servicePrincipalBaseName = "tf-sp"
  $subscriptionId = az account list `
    --query "[?isDefault][id]" `
    --all `
    --output tsv

  # we need to recreate the Service Principal to get the secret
  $servicePrincipalId = az ad sp list `
    --filter "startswith(displayName, '$servicePrincipalBaseName')" `
    --query "[].objectId" `
    --output tsv
  if($servicePrincipalId){ 
    az ad sp delete --id $servicePrincipalId
  }
  $servicePrincipalName = "http://$servicePrincipalBaseName-$uniqueId"
  $clientSecret = az ad sp create-for-rbac `
  --name $servicePrincipalName `
  --role Contributor `
  --scopes "/subscriptions/$subscriptionId" `
  --query password `
  --output tsv

  $clientId = az ad sp show `
  --id $servicePrincipalName `
  --query appId `
  --output tsv 

  $tenantId = az ad sp show `
    --id $servicePrincipalName `
    --query appOwnerTenantId `
    --output tsv

  # setting environment variables that terraform is expecting
  [System.Environment]::SetEnvironmentVariable("ARM_SUBSCRIPTION_ID", $subscriptionId)
  [System.Environment]::SetEnvironmentVariable("ARM_CLIENT_SECRET", $clientSecret)
  [System.Environment]::SetEnvironmentVariable("ARM_CLIENT_ID", $clientId)
  [System.Environment]::SetEnvironmentVariable("ARM_TENANT_ID", $tenantId)
}
