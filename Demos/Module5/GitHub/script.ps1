$user = 'daradu'
$email = 'radudanielro@yahoo.com'

# generate new SSH key
ssh-keygen -C $email

# add the key to GH account
cat C:\Users\$user\.ssh\id_rsa.pub

# add repo in GitHub
cd Labs\MathTrick\Chained\MT3Chained-Web

# create initial commit
git init
git add .
git commit -m "Initial check-in"

# create repo in GitHub

# push changes
git remote add origin https://github.com/ivee-tech/MT3Chained-Web.git
git branch -M main
git push -u origin main

# connect to Azure
Connect-AzAccount
Get-AzContext 

# create SP
$AKS_RESOURCE_GROUP = 'k8s-tech-brief-rg'
$YOUR_INITIALS = 'dr'
$SUFFIX = 'xyz001'
$resourceGroupId = (Get-AzResourceGroup -Name $AKS_RESOURCE_GROUP).ResourceId
$SP_NAME = "sp-aks-$($YOUR_INITIALS)$SUFFIX"
Write-Host "Service Principal Name:" $SP_NAME
$azureContext = Get-AzContext
$servicePrincipal = New-AzADServicePrincipal -DisplayName $SP_NAME -Role Contributor -Scope $resourceGroupId
$output = @{ 
    clientId = $($servicePrincipal.ApplicationId)
    clientSecret = $([System.Net.NetworkCredential]::new('',$servicePrincipal.Secret).Password)
    subscriptionId = $($azureContext.Subscription.Id)
    tenantId = $($azureContext.Tenant.Id)
}
$output | ConvertTo-Json



# get the ACR server name
$ACR_SERVER_NAME = (az acr show -n $ACR_NAME --query loginServer -o tsv)

# create workflow.yaml and populate it with correct values 
$Path1 = "C:\s\wp-tech-brief\Labs\Module5\workflows"
$Path2 = "C:\s\wp-tech-brief\Labs\MathTrick\Chained\MT3Chained-Web\.github\workflows"
$original_file = (Join-Path $Path1 workflow-web1.yaml)
$destination_file = (Join-Path $Path2 workflow.yaml)
(Get-Content $original_file) | Foreach-Object {
    $_ -replace "<appName>", "mt3chained-web" `
        -replace "<acrServerName>", $ACR_SERVER_NAME
} | Set-Content $destination_file

# push workflow.yaml
git add .
git commit -m "Create the workflow.yaml"
git push

# add AKS deployment step
$Path1 = "C:\s\wp-tech-brief\Labs\Module5\workflows"
$Path2 = "C:\s\wp-tech-brief\Labs\MathTrick\Chained\MT3Chained-Web\.github\workflows"
$original_file = (Join-Path $Path1 workflow-web2.yaml)
$destination_file = (Join-Path $Path2 workflow.yaml)
(Get-Content $original_file) | Foreach-Object {
    $_ -replace "<appName>", "mt3chained-web" `
    -replace "<acrServerName>", $ACR_SERVER_NAME `
    -replace "<clusterName>", $AKS_NAME `
    -replace "<clusterResourceGroup>", $AKS_RESOURCE_GROUP `
    -replace "<namespaceName>", "default"
} | Set-Content $destination_file

# replace ACR server
$Path = "C:\s\wp-tech-brief\Labs\MathTrick\Chained\MT3Chained-Web"
(Get-Content (Join-Path $Path k8s-deployment.yaml)).replace("somecontainerrepo", $ACR_SERVER_NAME) | Set-Content (Join-Path $Path k8s-deployment.yaml)

# push changes
git add .
git commit -m "Update the the workflow.yaml and k8s-deployment.yaml"
git push
