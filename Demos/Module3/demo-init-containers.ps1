function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy init-dep" "Kubectl command:" "Command"
    kubectl delete deploy init-dep
    ExitScript
}

# Change to the demo folder
Set-Location InitContainers
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Deployments Page"
SendMessageToCI "The following demo illustrates Init Containers Pods" "Init Containers:" "Info"

DisplayStep "Next Step - Creates a multi-container workload with Init Containers"
SendMessageToCI "kubectl apply -f init-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f init-dep.yaml

DisplayStep "Click on any of the new pods to view Pod Details.  Watch the containers tabs"

CleanUp
