function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy multi-dep" "Kubectl command:" "Command"
    kubectl delete deploy multi-dep
    ExitScript
}

# Change to the demo folder
Set-Location MultiContainerPods
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Deployments Page"
SendMessageToCI "The following demo illustrates multi-container Pods" "Multi-Container Pods:" "Info"

DisplayStep "Next Step - Creates multi-container workload with 1 container that doesn't start and 1 that fails after a while"
SendMessageToCI "kubectl apply -f multi-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f multi-dep.yaml

DisplayStep "Click on any of the new pods to view Pod Details.  Watch the containers tabs"

CleanUp