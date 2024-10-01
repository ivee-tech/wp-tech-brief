docker build -t planets-web-app .

docker run -p 8090:80 planets-web-app

docker push daradu/planets-web-app:latest

$imageName = 'planets-web-app'
$tag = '0.0.1'
$img = "${imageName}:${tag}"
$acrName = 'ktbacr'
$rns = 'itp'
$svr = "${acrName}.azurecr.io"

az acr login -n $acrName

docker tag $img ${svr}/${rns}/${img}
docker push ${svr}/${rns}/${img}

# k8s
kubectl apply -f planets-web-app-dep.yaml
kubectl apply -f planets-web-app-svc.yaml

# kubectl delete -f planets-web-app-dep.yaml
# kubectl delete -f planets-web-app-svc.yaml

kubectl apply -f manifest.yaml