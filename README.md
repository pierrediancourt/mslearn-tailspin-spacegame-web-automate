# Extended MSLearn lab

This is a basically a *mostly* automated mashup of the result of various learning paths provided by [Microsoft](https://docs.microsoft.com)  

## Dev-like usage

Clone your forked repository on your Windows or Linux machine (with powershell 7.x installed).  
Run the following powershell commands on your machine from the root of the repository :  

```powershell
./RunLab.ps1 # this is verbose
```

Alternatively, to get closer to the "Prod-like usage" you can run  

```powershell
./RunLab.ps1 -As Prod # this uses a service principal and is not so verbose
```

## Clean up
  
Simply run :

```powershell
./CleanLab.ps1
```

It will take care of everything.  

## Prod-like usage

### Setup

You need an azure devops organization (trial mode is alright).  
Fork this repository.  
Create a project, go to "Pipelines" and click "New pipeline".  
Click "Github" as it's where the code repository is located and choose the right repository.  
You will be asked to create a new commit with a new file named "azure-pipelines.yml".  
Make it so that it's commited on a new branch as a pull request.  
On Github, close the pull request and delete the branch as we don't need of want the commit Azure DevOps forced us to create.  
On Azure DevOps, go to "Project Settings" > "Service connections".  
Click "New service connection" and select "Azure Resource Manager".  
Click "Service principal (automatic)", name it "mslearn-tailspin-spacegame-web-automate_pipeline" and just click next.  
Clone your forked repository on your Windows or Linux machine (with powershell 7.x installed).  
Now, run the following powershell commands on your machine from the root of the repository :  

```powershell
git checkout -b terraform origin/terraform
./SetupAzureEnvironment.ps1 -ServicePrincipal $True -Location francecentral # francecentral being the azure region where the terraform config will be stored
echo $env:ARM_SUBSCRIPTION_ID
echo $env:ARM_CLIENT_SECRET
echo $env:ARM_CLIENT_ID
echo $env:ARM_TENANT_ID
```

/!\ don't close this powershell window /!\
Use the last 4 outputs to fill a new "Variable Group" named "Release" on the Azure DevOps website ("Pipelines" > "Library" > "Variable Groups")  
In this group, add another variable named "ResourceGroupLocation" with your prefered azure region (ex: francecentral)  
Also create a variable named "StorageAccountName" with the value found in the powershell logs like the following : storage_account_name = "tfsa7943"  
Don't forget to save this page by using the button on the top.  
  
You can now close the powershell window if you like.
From now on, you can run the pipeline as it pleases you.
When successful, this pipelines gives you a link to the published website. Just look for something like "http://tailspin-space-game-web-dev-2455.azurewebsites.net/" !  
  
## Clean up
  
Simply run :

```powershell
./CleanLab.ps1
```

It will take care of everything.  
