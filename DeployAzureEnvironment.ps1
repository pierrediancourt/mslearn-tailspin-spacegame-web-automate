param(
  [Parameter(Mandatory)]
  [string] $RequireApproval = $True
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Write-Verbose "Initiating terraform"
terraform init -backend-config="$PSScriptRoot\backend.tfvars" -input=false # input false necessary for the job to crash if we don't pass every mandatory variables to terraform
if(! $?){
  Write-Error "terraform init command failed"
  exit 1
}
if($RequireApproval){
    $planName = "tfLab$(Get-Date -UFormat %Y%m%d).tfplan"
    terraform plan -out="$planName"
    if(! $?){
      Write-Error "terraform plan command failed"
      exit 1
    }
    Write-Verbose "Editing the azure environment"
    terraform apply "$planName" -input=false # input false necessary for the job to crash if we don't pass every mandatory variables to terraform
    if(! $?){
      Write-Error "terraform apply command failed"
      exit 1
    }
    Remove-Item "$planName"
}
else{
    Write-Verbose "Editing the azure environment"
    # we skip the "terraform plan" command here as we're supposed to run a valid plan (previously tested and approved)
    terraform apply -auto-approve -input=false # input false necessary for the job to crash if we don't pass every mandatory variables to terraform
    if(! $?){
      Write-Error "terraform apply command failed"
      exit 1
    }
}
Write-Verbose "The azure environment is setup"
Write-Verbose "Getting the azure environment details"
terraform output
if(! $?){
  Write-Error "terraform output command failed"
  exit 1
}
