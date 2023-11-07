function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy -l app=demo" "Kubectl command:" "Command"
    kubectl delete -f daemonset.yaml
    ExitScript
}

# Change to the demo folder
Set-Location .\Daemonsets
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page"
DisplayStep "Turn OFF Mini and Micro Pods"
DisplayStep "Turn ON Show Containers"
DisplayStep "Navigate to the Controllers - Daemonsets and select All Namespaces"
SendMessageToCI "The following demo illustrates how to deploy Deamonsets" "Deamonsets:" "Info"

DisplayStep "Next Step - Creates a Deamonset"
kubectl apply -f daemonset.yaml

CleanUp
