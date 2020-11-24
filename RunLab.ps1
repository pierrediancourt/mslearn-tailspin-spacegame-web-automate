param(
  [string] $As = "Dev",
  [string] $Location = "francecentral"
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$LogFilePath = "$PSScriptRoot\RunLab-$(Get-Date -UFormat %Y%m%d).log"

if($As -eq "Dev"){
    & "$PSScriptRoot\SetupAzureEnvironment.ps1" -Verbose -Location $Location | Tee-Object -Append $LogFilePath
    & "$PSScriptRoot\DeployAzureEnvironment.ps1" -Verbose -RequireApproval $True | Tee-Object -Append $LogFilePath
}
else{ # for Prod through CI/CD pipeline
    & "$PSScriptRoot\SetupAzureEnvironment.ps1" -ServicePrincipal $True -Location $Location
    Start-Sleep -Seconds 10 # giving some time for the ServicePrincipal to finish propagating its rights over the storage account so that "terraform init" doesn't crash
    # we could easily do something prettier to solve this
    & "$PSScriptRoot\DeployAzureEnvironment.ps1" -RequireApproval $False
}
