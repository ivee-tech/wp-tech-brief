$AKS_RESOURCE_GROUP = 'ktb-np-rg'
$LOCATION = 'AustraliaEast'

az group create --location $LOCATION `
    --resource-group $AKS_RESOURCE_GROUP

$VM_SKU="Standard_D2as_v5"
$AKS_NAME="ktb-np-aks"
az aks create --node-count 2 `
    --generate-ssh-keys `
    --node-vm-size $VM_SKU `
    --network-plugin azure `
    --network-policy azure `
    --name $AKS_NAME  `
    --resource-group $AKS_RESOURCE_GROUP

az aks get-credentials --name $AKS_NAME `
    --resource-group $AKS_RESOURCE_GROUP

kubectl config current-context

$ns = 'np-demo'
kubectl get ns
kubectl create ns $ns
# kubectl delete ns $ns

kubectl apply -f .\np-default-deny.yaml -n $ns
kubectl apply -f .\np-access-granted.yaml -n $ns

kubectl get netpol -n $ns

kubectl create deployment nginx --image=nginx --replicas=2 -n $ns
kubectl expose deployment nginx --port=80 -n $ns

kubectl run -it --rm t1 --image=busybox --restart=Never -n $ns -- sh 
# wget -O- nginx:80 --timeout=2
kubectl run -it --rm t2 --image=busybox --restart=Never -l access=granted -n $ns -- sh
# wget -O- nginx:80 --timeout=2

kubectl delete ns $ns
