function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy workload-dep" "Kubectl command:" "Command"
    kubectl delete deploy workload-dep
    SendMessageToCI "kubectl delete svc workload-svc" "Kubectl command:" "Command"
    kubectl delete svc workload-svc
    ExitScript
}

# Change to the demo folder
Set-Location Services
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Services page"
SendMessageToCI "The following demo illustrates different types of Services in Kubernetes" "Services:" "Info"

DisplayStep "Next Step - Create initial workload with a ClusterIP service"
SendMessageToCI "kubectl apply -f workload-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-dep.yaml
SendMessageToCI "kubectl apply -f svc-clusterip.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-svc-clusterip.yaml

# test with temp pod
kubectl run -it --rm test --image busybox -- sh
# wget -O- http://workload-svc:8100

DisplayStep "Next Step - Upgrades the service to a NodePort"
SendMessageToCI "type: NodePort" "Service YAML Changes:" "Code"
kubectl apply -f workload-svc-nodeport.yaml

# test with temp pod
kubectl run -it --rm test --image busybox -- sh
# wget -O- http://workload-svc:8100
# wget -O- http://<node>:<nodeport>

DisplayStep "Next Step - Upgrades the service to a LoadBalancer"
SendMessageToCI "type: LoadBalancer" "Service YAML Changes:" "Code"
kubectl apply -f workload-svc-loadbalancer.yaml

DisplayStep "Wait about a minute or two for the external IP to be available and active"
DisplayStep "Click on the external IP to bring up the website"
DisplayStep "Watch the website as it refreshes, showing how it reaches a different pod after refresh (internal load balancer working)"

DisplayStep "Next Step - Update the deployment to show how the services switches to new pods"
SendMessageToCI "kubectl apply -f workload-dep-update.yaml --record" "Kubectl command:" "Command"
kubectl apply -f workload-dep-update.yaml

CleanUp