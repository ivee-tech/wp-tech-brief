# install KIC
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# create a gateway class and a gateway
kubectl apply -f ./kong-gway.yaml

# install kong
helm repo add kong https://charts.konghq.com
helm repo update
helm install kong kong/ingress -n kong --create-namespace 

# test connectivity
$PROXY_IP=$(kubectl get svc --namespace kong kong-gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $PROXY_IP

curl -i $PROXY_IP

# deploy echo service
kubectl apply -f https://docs.konghq.com/assets/kubernetes-ingress-controller/examples/echo-service.yaml

# deploy Gateway API route config
kubectl apply -f ./echo-route.yaml

# deploy echo ingress
kubectl apply -f ./echo-ing.yaml


# test routing rule
curl -i $PROXY_IP/echo
