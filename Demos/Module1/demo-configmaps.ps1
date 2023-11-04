function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy workload-1-dep" "Kubectl command:" "Command"
    kubectl delete deploy -l scope=demo
    SendMessageToCI "kubectl delete configmap -l scope=demo" "Kubectl command:" "Command"
    kubectl delete configmap -l scope=demo
    ExitScript
}

# Change to the demo folder
Set-Location Configuration
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Deployments page"
SendMessageToCI "The following demo illustrates various ways to use ConfigMaps in Kubernetes" "ConfigMaps:" "Info"

DisplayStep "Next Step - Creates initial configuration and deployment"
SendMessageToCI "kubectl apply -f simple-configmap.yaml" "Kubectl command:" "Command"
kubectl apply -f simple-configmap.yaml
SendMessageToCI "kubectl apply -f simple-configmap2.yaml" "Kubectl command:" "Command"
kubectl apply -f simple-configmap2.yaml
SendMessageToCI "kubectl apply -f file-configmap.yaml" "Kubectl command:" "Command"
kubectl apply -f file-configmap.yaml
SendMessageToCI "kubectl apply -f workload-1-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-1-dep.yaml

DisplayStep "Shell into the Pod and review its settings and files"

CleanUp