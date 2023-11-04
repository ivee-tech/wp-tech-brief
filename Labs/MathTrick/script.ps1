$AKS_RESOURCE_GROUP = 'k8s-tech-brief-rg'
$ACR_NAME = 'ktbacr'
$KV_NAME = 'ktb-kv'

# Chained

# create images in ACR
.\buildmt3chainedallacr.ps1 -acrname $ACR_NAME

# install helm chart (in ns chained) 
cd .\Chained\Helm
helm install chaineddemo mt3chained # -n default

helm uninstall chaineddemo

# Gateway

# create images in ACR
.\buildmt3gatewayallacr.ps1 -acrname $ACR_NAME

# install helm chart 
cd .\Gateway\Helm
helm install gatewaydemo mt3gateway # -n default


# Bridge to K8S

# configure namespace
kubectl config set-context --current --namespace chained
kubectl config set-context --current --namespace default

