# enable VPA
$rgName = 'k8s-tech-brief-rg2'
$aksName = 'ktb-aks2'
az aks update -n $aksName -g $rgName --enable-vpa
kubectl get pods -n kube-system

kubectl config use-context $aksName

# goldilocks
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm repo update
kubectl create namespace goldilocks
helm install goldilocks --namespace goldilocks fairwinds-stable/goldilocks

# run goldilocks dahsboard
kubectl -n goldilocks port-forward svc/goldilocks-dashboard 8080:80

# create ns gl
$ns = 'gl'
kubectl create ns $ns
# kubectl delete ns $ns

# label a NS for goldilocks
kubectl label ns gl goldilocks.fairwinds.com/enabled=true

# deploy hamster (including VPA config)
kubectl apply -f hamster.yaml -n $ns
# kubectl delete -f hamster.yaml -n $ns

# check deployments
kubectl get deploy -n $ns
# check pods
kubectl get pods -l app=hamster -n $ns

# kubectl delete ns $ns

# troubleshoot
$tns = 'goldilocks'
kubectl get pods -n $tns
$pod = 'goldilocks-controller-69bb544c8d-qzmtd'
kubectl logs $pod -n $tns
