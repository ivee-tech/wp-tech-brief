# this is not provided with the Demos, uses the Lab located in Labs\Module6
Set-Location .\Labs\Module6

$AKS_RESOURCE_GROUP = "k8s-tech-brief-rg"
$LOCATION = "AustraliaEast"
$AKS_NAME = "ktb-aks"
$KV_NAME = "ktb-kv"
$TENANT_ID = (az aks show --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP --query "{tenantId:identity.tenantId}" -o tsv)

# enable KV add-on
az aks addon enable `
    --addon azure-keyvault-secrets-provider `
    --name $AKS_NAME `
    --resource-group $AKS_RESOURCE_GROUP

# check add-ons
az aks addon list --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP -o table

# get KV ID
$KV_ID = (az keyvault list --query "[? name=='$($KV_NAME)'].{id:id}" -o tsv)

# optionally, give current user KV Admin permissions 
# get current user ID
$CURRENT_USER_ID = (az ad signed-in-user show --query "{id:id}" -o tsv)
# give Admin permissions to current user
az role assignment create `
    --role "Key Vault Administrator" `
    --assignee-object-id $CURRENT_USER_ID `
    --scope $KV_ID

# create sample secret
az keyvault secret set `
    --vault-name $KV_NAME `
    --name SampleSecret `
    --value "Highly sensitive information: XYZ-001"
# check secrets
az keyvault secret list --vault-name $KV_NAME -o table

# check list of identities
az identity list --query "[].{name:name,ClientId:clientId}" -o table

# get the KV Secret Provider Identity
$AKS_KV_IDENTITY = (az identity list --query "[? contains(name,'azurekeyvaultsecretsprovider')].{principalId:principalId}" -o tsv)
$AKS_KV_CLIENT_ID = (az identity list --query "[? contains(name,'azurekeyvaultsecretsprovider')].{clientId:clientId}" -o tsv)

# assign KV permissions to AKS KV Secret Provider Identity
az role assignment create `
    --role "Key Vault Secrets User" `
    --assignee-object-id $AKS_KV_IDENTITY `
    --scope $KV_ID

# deploy SecretProviderClass
kubectl apply -f .\spc.yaml
kubectl get SecretProviderClass

# apply pod which consumes secret
kubectl apply -f .\pod-kv.yaml
# kubectl delete -f .\pod-kv.yaml

# verify sample secret in pod
kubectl exec -it pod-kv -- cat /mnt/secrets-store/SampleSecret

# verify secret as ENV var
kubectl exec -it pod-kv -- printenv

# check the secret in K8S
kubectl get secret

# delete pod
kubectl delete pod pod-kv



