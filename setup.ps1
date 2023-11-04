$AKS_RESOURCE_GROUP="k8s-tech-brief-rg"
$LOCATION="australiaeast"
$VM_SKU="Standard_D2as_v5"
$AKS_NAME="ktb-aks"
$NODE_COUNT="3"
$ACR_NAME = 'ktbacr'
$KV_NAME = 'ktb-kv'

# create RG
az group create --location $LOCATION `
    --resource-group $AKS_RESOURCE_GROUP


# create ACR
$ACR_ID=$(az acr create --sku Basic --name $ACR_NAME --resource-group $AKS_RESOURCE_GROUP --query id -o tsv)
$ACR_ID

# create KV
az keyvault create --name $KV_NAME `
    --resource-group $AKS_RESOURCE_GROUP `
    --enable-rbac-authorization true `
    --sku Standard


# create cluster
az aks create --node-count $NODE_COUNT `
    --generate-ssh-keys `
    --node-vm-size $VM_SKU `
    --name $AKS_NAME `
    --resource-group $AKS_RESOURCE_GROUP

kubectl config get-contexts
kubectl config current-context

# connect to the cluster
az aks get-credentials --name $AKS_NAME `
    --resource-group $AKS_RESOURCE_GROUP `
    --file $HOME/.kube/config

# verify connection
kubectl get nodes

# stop cluster
az aks stop --name $AKS_NAME `
    --resource-group $AKS_RESOURCE_GROUP

# start cluster
$AKS_RESOURCE_GROUP="k8s-tech-brief-rg"
$AKS_NAME="ktb-aks"
az aks start --name $AKS_NAME `
    --resource-group $AKS_RESOURCE_GROUP

# assign AcrPull permissions to the cluster
$AKS_ID = $(az ad sp list --display-name "$AKS_NAME" --query [0].appId -o tsv)
$AKS_POOL_ID = $(az ad sp list --display-name "$AKS_NAME-agentpool" --query [0].appId -o tsv)
    
az role assignment create --role "AcrPull" --assignee $AKS_ID --scope $ACR_ID 
az role assignment create --role "AcrPull" --assignee $AKS_POOL_ID --scope $ACR_ID

# troubleshoot ACR connectivity
# check assignments
$subId = "2ef01a24-f9c4-4a9f-bca8-7d0ca8fe11fa"
$rg = 'k8s-tech-brief-rg'
$acrName = 'ktbacr'
$ACR_ID = "/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.ContainerRegistry/registries/$acrName"
az role assignment list --scope $ACR_ID -o table

# attach ACR
$aksName = 'ktb-aks'
az aks update -n $aksName -g $rg --attach-acr $ACR_ID

# install cluster info
helm repo add scubakiz https://scubakiz.github.io/clusterinfo/
helm repo update
helm install clusterinfo scubakiz/clusterinfo

# forward the service to local
kubectl port-forward svc/clusterinfo 5252:5252 -n clusterinfo

# navigate to http://localhost:5252

# Module 3 

# install ingress controller
<#
helm install ingress-nginx ingress-nginx/ingress-nginx `
    --namespace ingress-nginx --create-namespace `
    --set controller.nodeSelector."kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux
# upgrade
helm upgrade --reuse-values nginx-ingress ingress-nginx/ingress-nginx -n ingress-nginx
# OR
kubectl set image deployment/nginx-ingress-ingress-nginx-controller `
  controller=registry.k8s.io/ingress-nginx/controller:v3.0.0 `
  -n ingress-nginx
#>


# re-install
helm repo ls
# helm repo rm ingress-nginx
$repo = 'https://kubernetes.github.io/ingress-nginx' # 'https://github.com/nginxinc/kubernetes-ingress'  # 
helm repo add ingress-nginx $repo
helm repo update
helm upgrade --install ingress-nginx ingress-nginx `
     --repo $repo `
     --namespace ingress-nginx --create-namespace `
     --set controller.nodeSelector."kubernetes\.io/os"=linux `
     --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux `
     --set controller.service.externalTrafficPolicy=Local `
     --set defaultBackend.image.image=defaultbackend-amd64:1.5
    
# check ingress controller
kubectl get svc -n ingress-nginx `
    -o=custom-columns=NAME:.metadata.name,TYPE:.spec.type,IP:.status.loadBalancer.ingress[0].ip
kubectl describe deployment nginx-ingress-ingress-nginx-controller -n ingress-nginx

# uninstall
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete ns ingress-nginx

# simple install of nginx controller
# Add the Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install ingress-nginx ingress-nginx/ingress-nginx `
    --namespace ingress-nginx `
    --set controller.replicaCount=2

kubectl describe deploy ingress-nginx-controller -n ingress-nginx

# K8S v1.24 breaks nginx controller
# below didn't fix it
kubectl set image deployment/ingress-nginx-controller `
    controller=registry.k8s.io/ingress-nginx/controller:v3.0.0 `
    -n ingress-nginx
# mitigation???
# get svc backup
kubectl get svc ingress-nginx-controller -n ingress-nginx -o yaml >> backup_ingress-nginx-controller.yaml
# edit svc
kubectl edit service ingress-nginx-controller -n ingress-nginx
# add annotation
# service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
# save svc




# Module 7


# install KEDA
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda `
    --create-namespace --namespace keda

# install OSM

# install OSM CLI
wget https://github.com/openservicemesh/osm/releases/download/v1.1.1/osm-v1.1.1-windows-amd64.zip -o osm.zip
# wget https://github.com/openservicemesh/osm/releases/download/v1.1.2/osm-v1.1.2-windows-amd64.zip -o osm.zip
# use admin console
Expand-Archive -LiteralPath .\osm.zip -DestinationPath C:\windows\system32

# MULTIPLE ISSUES, try using aks add-on instead
# install OSM in the cluster, based on cluster setup guide
# Replace osm-system with the namespace where OSM will be installed
$osm_namespace="osm-system"
# Replace osm with the desired OSM mesh name
$osm_mesh_name="osm"
osm install `
    --mesh-name "$osm_mesh_name" `
    --osm-namespace "$osm_namespace" `
    --set=osm.enablePermissiveTrafficPolicy=true

# delete this OSM
osm uninstall mesh
# delete ns
kubectl delete ns $osm_namespace

# install chaos-mesh
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm update
helm install chaos-mesh chaos-mesh/chaos-mesh `
    --namespace=chaos-testing --create-namespace `
    --set chaosDaemon.runtime=containerd `
    --set chaosDaemon.socketPath=/run/containerd/containerd.sock

# check chaos-mesh running
kubectl get pods --namespace chaos-testing `
    -l app.kubernetes.io/instance=chaos-mesh `
    -o=customcolumns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName


# enable OSM add-on
az aks addon list `
  --resource-group $AKS_RESOURCE_GROUP `
  --name $AKS_NAME `
az aks enable-addons `
  --resource-group $AKS_RESOURCE_GROUP `
  --name $AKS_NAME `
  --addons open-service-mesh

# verify OSM add-on
az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_NAME  --query 'addonProfiles.openServiceMesh.enabled'

# check OSM mesh is running
kubectl describe deployment -n kube-system osm-controller # -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
# check OSM components
kubectl get deployments -n kube-system --selector app.kubernetes.io/name=openservicemesh.io
kubectl get pods -n kube-system --selector app.kubernetes.io/name=openservicemesh.io
kubectl get services -n kube-system --selector app.kubernetes.io/name=openservicemesh.io

# verify config
kubectl get meshconfig osm-mesh-config -n kube-system -o yaml

# scale down node pool to 0
$NODE_POOL = 'nodepool2'
$NODE_COUNT = 0
az aks nodepool scale --cluster-name $AKS_NAME `
    --name $NODE_POOL `
    --resource-group $AKS_RESOURCE_GROUP `
    --node-count $NODE_COUNT
