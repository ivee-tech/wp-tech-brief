function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy canary-1-dep canary-2-dep" "Kubectl command:" "Command"
    kubectl delete deploy canary-1-dep canary-2-dep    
    SendMessageToCI "kubectl delete svc canary-svc" "Kubectl command:" "Command"
    kubectl delete svc canary-svc
    ExitScript
}

# Change to the demo folder
Set-Location CanaryDeployments
. "..\..\CISendMessage.ps1"


StartScript
DisplayStep "Open the Deployments page"
SendMessageToCI "The following demo illustrates a basic canary deployment using Services" "Canary deployments:" "Info"

DisplayStep "Next Step - Creates yellow workload and service"
SendMessageToCI "kubectl apply -f canary-1-dep.yaml" "Kubectl commands:" "Command"
kubectl apply -f canary-1-dep.yaml
SendMessageToCI "kubectl apply -f canary-svc.yaml" "Kubectl commands:" "Command"
kubectl apply -f canary-svc.yaml

DisplayStep "Open the Services page"

DisplayStep "Next Step - Creates red workload with the same label"
SendMessageToCI "kubectl apply -f canary-2-dep.yaml" "Kubectl commands:" "Command"
kubectl apply -f canary-2-dep.yaml

DisplayStep "Observe how service can select either deployment"

CleanUp