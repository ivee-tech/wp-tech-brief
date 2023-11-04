Set-Location .\OSM-0

# create ns
kubectl create namespace bookstore
kubectl create namespace bookbuyer
kubectl create namespace bookthief
kubectl create namespace bookwarehouse

# add OSM namespaces
osm namespace add bookstore bookbuyer bookthief bookwarehouse

# creates pods, services, SAs
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.0/manifests/apps/bookbuyer.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.0/manifests/apps/bookthief.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.0/manifests/apps/bookstore.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.0/manifests/apps/bookwarehouse.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.0/manifests/apps/mysql.yaml

# check installation
kubectl get pods,deployments,serviceaccounts -n bookbuyer
kubectl get pods,deployments,serviceaccounts -n bookthief

kubectl get pods,deployments,serviceaccounts,services,endpoints -n bookstore
kubectl get pods,deployments,serviceaccounts,services,endpoints -n bookwarehouse


# view UIs
cp .env.example .env
./scripts/port-forward-all.sh
# alternatively, use different ports
BOOKBUYER_LOCAL_PORT=7070 BOOKSTOREv1_LOCAL_PORT=7071 BOOKSTOREv2_LOCAL_PORT=7072 BOOKTHIEF_LOCAL_PORT=7073 BOOKSTORE_LOCAL_PORT=7074 ./scripts/port-forward-all.sh


# bookbuyer UI
$BOOKBUYER_NAMESPACE = 'bookbuyer'
$BOOKBUYER_LOCAL_PORT=8080
$POD="$(kubectl get pods --selector app=bookbuyer -n "$BOOKBUYER_NAMESPACE" --no-headers --output=custom-columns=NAME:.metadata.name)"
kubectl port-forward "$POD" -n "$BOOKBUYER_NAMESPACE" "$BOOKBUYER_LOCAL_PORT":14001

# bookbuyer
$BOOKBUYER_NAMESPACE = 'bookbuyer'
$POD="$(kubectl get pods --selector app=bookbuyer -n "$BOOKBUYER_NAMESPACE" --no-headers --output=custom-columns=NAME:.metadata.name)"
kubectl port-forward "$POD" -n "$BOOKBUYER_NAMESPACE" 15000:15000

# clean-up
kubectl delete ns bookstore
kubectl delete namespace bookbuyer
kubectl delete namespace bookthief
kubectl delete namespace bookwarehouse
Set-Location ..