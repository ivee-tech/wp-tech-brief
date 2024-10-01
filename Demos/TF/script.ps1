# init
terraform init -upgrade

# plan
terraform plan -out main.tfplan

# apply
terraform apply main.tfplan

# verify
$resource_group_name=$(terraform output -raw resource_group_name)
$aks_name=$(terraform output -raw kubernetes_cluster_name)

az aks list --resource-group $resource_group_name --query "[].name" --output table

az aks get-credentials --resource-group $resource_group_name --name $aks_name

# echo "$(terraform output kube_config)" > ./azurek8s

# cat ./azurek8s

kubectl get nodes

# deploy app
kubectl apply -f aks-store-quickstart.yaml
kubectl get pods
kubectl get service store-front --watch


# destroy
$sp=$(terraform output -raw sp)
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
# delete SP
az ad sp delete --id $sp