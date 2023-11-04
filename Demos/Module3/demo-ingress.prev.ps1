function CleanUp ([string] $done) {
    StartCleanUp $done    
    SendMessageToCI "kubectl delete ns development" "Kubectl command:" "Command"
    kubectl delete ns development
    SendMessageToCI "kubectl delete ns staging" "Kubectl command:" "Command"
    kubectl delete ns staging
    SendMessageToCI "kubectl delete deploy default-dep -n default" "Kubectl command:" "Command"
    kubectl delete deploy default-dep -n default
    SendMessageToCI "kubectl delete svc default-svc -n default" "Kubectl command:" "Command"
    kubectl delete svc default-svc -n default
    SendMessageToCI "kubectl delete ing default-backend.yaml -n default" "Kubectl command:" "Command"
    kubectl delete ing default-ingress-backend -n default
    ExitScript
}

# Change to the demo folder
Set-Location Ingress
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Deployments page"
SendMessageToCI "The following demo illustrates how an Ingress Controller works in Kubernetes" "Ingress Controller:" "Info"

DisplayStep "Next Step - Creates the development namespace"
SendMessageToCI "kubectl create ns development" "Kubectl command:" "Command"
kubectl create ns development

DisplayStep "Click Deployments - Change the Namespace dropdown to development"

DisplayStep "Next Step - Creates all the deployments and service in development namespace"
SendMessageToCI "kubectl apply -f blue-dep.yaml -f blue-svc-lb.yaml -n development" "Kubectl command:" "Command"
kubectl apply -f blue-dep.yaml -f blue-svc-lb.yaml -n development
SendMessageToCI "kubectl apply -f red-dep.yaml -f red-svc-lb.yaml -n development" "Kubectl command:" "Command"
kubectl apply -f red-dep.yaml -f red-svc-lb.yaml -n development
SendMessageToCI "kubectl apply -f yellow-dep.yaml -f yellow-svc-lb.yaml -n development" "Kubectl command:" "Command"
kubectl apply -f yellow-dep.yaml -f yellow-svc-lb.yaml -n development

DisplayStep "Navigate to Ingress page"
DisplayStep "Observe how there are 4 external IP addresses"
DisplayStep "Next Step - Creates Ingress rules for each service"
SendMessageToCI "kubectl apply -f colors-ingress.yaml -n development" "Kubectl command:" "Command"
kubectl apply -f colors-ingress.yaml -n development

DisplayStep "Verify all the rules work???: http://<ip>/blue/ etc"

DisplayStep "Next Step - Change all the other services to ClusterIP"
SendMessageToCI "kubectl apply -f blue-svc-cip.yaml -f red-svc-cip.yaml -f yellow-svc-cip.yaml -n development" "Kubectl command:" "Command"
kubectl delete -f blue-svc-lb.yaml -f red-svc-lb.yaml -f yellow-svc-lb.yaml -n development
kubectl apply -f blue-svc-cip.yaml -f red-svc-cip.yaml -f yellow-svc-cip.yaml -n development

DisplayStep "Next Step - Creates the staging namespace"
SendMessageToCI "kubectl create ns staging" "Kubectl command:" "Command"
kubectl create ns staging

DisplayStep "Next Step - Creates all the deployments and service in staging namespace"
SendMessageToCI "kubectl apply -f blue-dep.yaml -f blue-svc-cip.yaml -n staging" "Kubectl command:" "Command"
kubectl apply -f blue-dep.yaml -f blue-svc-cip.yaml -n staging
SendMessageToCI "kubectl apply -f red-dep.yaml -f red-svc-cip.yaml -n staging" "Kubectl command:" "Command"
kubectl apply -f red-dep.yaml -f red-svc-cip.yaml -n staging
SendMessageToCI "kubectl apply -f yellow-dep.yaml -f yellow-svc-cip.yaml -n staging" "Kubectl command:" "Command"
kubectl apply -f yellow-dep.yaml -f yellow-svc-cip.yaml -n staging

DisplayStep "Click Deployments - Change the Namespace dropdown to staging"
DisplayStep "Navigate to Services.  Observe all are cluster Ips"
DisplayStep "Navigate to Ingress.  Observe there's no way to get to the services from external"

DisplayStep "Next Step - Delete ingress rule"
SendMessageToCI "kubectl apply -f colors-ingress.yaml -n development" "Kubectl command:" "Command"
kubectl delete ing colors-ingress -n development


DisplayStep "Next Step - Create namespace ingress rules"
SendMessageToCI "kubectl apply -f colors-ingress-development.yaml -n development" "Kubectl command:" "Command"
kubectl apply -f colors-ingress-development.yaml -n development
SendMessageToCI "kubectl apply -f colors-ingress-staging.yaml -n staging" "Kubectl command:" "Command"
kubectl apply -f colors-ingress-staging.yaml -n staging

DisplayStep "Navigate to Ingress in both namespaces"
DisplayStep "Verify all the rules work???: http://<ip>/staging/blue/, http://<ip>/development/blue/ etc"


DisplayStep "Click on the NGinx controller IP.  Notice it shows a 404"
DisplayStep "Next Step - Create default backend components"
SendMessageToCI "kubectl apply -f default-dep.yaml -f default-svc.yaml -f default-backend.yaml -n default" "Kubectl command:" "Command"
kubectl apply -f default-dep.yaml -f default-svc.yaml -f default-backend.yaml -n default

DisplayStep "Click on the NGinx controller IP.  Notice there's a page there now"

CleanUp