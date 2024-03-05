# ******** install nginx ingrexx controller ********
$ns = 'ingress-apps'
# Create a namespace for ingress resources
kubectl create namespace $ns

# Add the Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm upgrade ingress-nginx ingress-nginx/ingress-nginx `
    --namespace $ns `
    --set controller.replicaCount=2


# ******** install cert-manager ********
$ns = 'ingress-nginx'
# Label the cert-manager namespace to disable resource validation
kubectl label namespace $ns cert-manager.io/disable-validation=true
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
# Update your local Helm chart repository cache
helm repo update
# Install CRDs with kubectl
# $v = 'v1.9.1' # initial working version
$v = 'v1.13.3'
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$v/cert-manager.crds.yaml
# Install the cert-manager Helm chart
helm upgrade --install cert-manager jetstack/cert-manager `
  --namespace $ns `
  --version $v

# check, rollback, uninstall cert-manager
helm ls -n $ns
helm history cert-manager -n $ns
helm rollback cert-manager -n $ns
helm uninstall cert-manager -n $ns


# create cluster issuer
kubectl apply -f cluster-issuer.yaml --namespace $ns


# troubleshoot
kubectl get all -n $ns
kubectl get clusterissuer -n $ns
kubectl describe clusterissuer -n $ns

$ns1 = 'zz-apps'
kubectl get certificate tls-secret -n $ns1
kubectl describe certificate tls-secret -n $ns1
& "C:\tools\cmctl\cmctl.exe" status certificate tls-secret -n $ns1

# check private key
& "C:\tools\openssl\openssl.cmd" rsa -noout -text -in .\letsencrypt.key


# create ingress in the target namespace
$nst = 'geekready2022'
kubectl apply -f .\demo-app.yaml -n $nst
kubectl apply -f .\rose-app-ingress.yaml -n $nst
# kubectl delete ingress rose-app-ingress -n $nst