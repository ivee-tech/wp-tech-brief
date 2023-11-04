$location = 'AustraliaEast'
$rg = 'k8s-tech-brief-rg2'
$aksName = 'ktb-aks2'

# register AzureServiceMeshPreview
az feature register --namespace "Microsoft.ContainerService" --name "AzureServiceMeshPreview"
az feature show --namespace "Microsoft.ContainerService" --name "AzureServiceMeshPreview"
# refresh the Microsoft.ContainerService provider
az provider register --namespace Microsoft.ContainerService

# upgrade az aks extension
az upgrade
az extension add --name aks-preview
# OR
az extension update --name aks-preview

# create RG
az group create --name $rg --location $location

# create AKS cluster with mesh addon enabled
az aks create --resource-group $rg --name $aksName --enable-asm

# enable mesh addon for existing cluster
az aks mesh enable --resource-group $rg --name $aksName


# verify successful installation
az aks show --resource-group $rg --name $aksName  --query 'serviceMeshProfile.mode'

# get credentials for auth
az aks get-credentials --resource-group $rg --name $aksName

# verify Istio pods
kubectl get pods -n aks-istio-system

# enable automated side car injection for namespace
kubectl label namespace default istio.io/rev=asm-1-17

# download bookinfo.yaml from 
# https://raw.githubusercontent.com/istio/istio/release-1.7/samples/bookinfo/platform/kube/bookinfo.yaml

# deploy bookinfo app
kubectl apply -f bookinfo.yaml
# kubectl delete -f bookinfo.yaml

kubectl get services
kubectl get pods


# enable ingress gateway
az aks mesh enable-ingress-gateway --resource-group $rg --name $aksName --ingress-gateway-type external

# check the service mapped to the ingress gateway
kubectl get svc aks-istio-ingressgateway-external -n aks-istio-ingress

# deploy bookinfo external gateway and virtual service
kubectl apply -f .\bookinfo-external.yaml
# kubectl delete -f .\bookinfo-external.yaml

# get endpoints
$INGRESS_HOST_EXTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
$INGRESS_PORT_EXTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-external -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
$GATEWAY_URL_EXTERNAL="$($INGRESS_HOST_EXTERNAL):$($INGRESS_PORT_EXTERNAL)"
$GATEWAY_URL_EXTERNAL
# navigate to http://<GATEWAY_URL_EXTERNAL>/productpage
# OR
# check using curl
curl -s "http://${GATEWAY_URL_EXTERNAL}/productpage" | findstr "<title>"


# enable internal ingress gateway
az aks mesh enable-ingress-gateway --resource-group $rg --name $aksName --ingress-gateway-type internal

# check the service mapped to the ingress gateway
kubectl get svc aks-istio-ingressgateway-internal -n aks-istio-ingress

# deploy bookinfo internal gateway and virtual service
kubectl apply -f .\bookinfo-internal.yaml
# kubectl delete -f .\bookinfo-internal.yaml


# get endpoints
$INGRESS_HOST_INTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-internal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
$INGRESS_PORT_INTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-internal -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
$GATEWAY_URL_INTERNAL="$($INGRESS_HOST_INTERNAL):$($INGRESS_PORT_INTERNAL)"
$GATEWAY_URL_INTERNAL

# this SHOULD NOT be accessible in the browser
# http://$GATEWAY_URL_INTERNAL/productpage
# NOR this
curl -s "http://${GATEWAY_URL_INTERNAL}/productpage" | findstr "<title>"

# exec inside the pod and check the title
$pod = $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $pod -c ratings -- bash
# run this inside the container
curl -sS  "http://$GATEWAY_URL_INTERNAL/productpage"  | grep -o "<title>.*</title>"
