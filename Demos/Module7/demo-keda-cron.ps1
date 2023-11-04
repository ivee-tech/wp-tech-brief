function CleanUp ([string] $done) {
    StartCleanUp $done
    kubectl delete deployment workload-dep
    kubectl delete scaledobject cron-scaledobject
    ExitScript
}

# Change to the demo folder
Set-Location KEDA-Cron
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page"
DisplayStep "Turn ON Micro Pods"
DisplayStep "Navigate to the Deployments page"

DisplayStep "Next Step - Creates initial workload and Cron KEDA scaler"
SendMessageToCI "kubectl apply -f workload -f keda-cron.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-dep.yaml
kubectl apply -f keda-cron.yaml

DisplayStep "Observe pod replicas increase every 2nd minute and decrease every 4th minutes"
DisplayStep "Discuss how this can be used to scale a workload in preparation for a known event"

CleanUp