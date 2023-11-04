function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy pvc-pod-dep" "Kubectl command:" "Command"
    kubectl delete deploy pvc-volume-dep
    kubectl delete pvc pvc-volume-disk
    ExitScript
}

# Change to the demo folder
Set-Location AdvancedVolumes
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page.  Turn on Mini Pods"
DisplayStep "Navigate to the Deployments page"
SendMessageToCI "The following demo illustrates what happens when multiple Pods try to access the same disk on different nodes" "Advanced Volumes:" "Info"

DisplayStep "Next Step - Creates PVC and Deployment with 1 replica.  All will be fine"
SendMessageToCI "kubectl apply -f pvc-volume-disk.yaml -f pvc-volume-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f pvc-volume-disk.yaml
kubectl apply -f pvc-volume-dep.yaml

DisplayStep "Wait until the Pod is running"

DisplayStep "Next Step - Increases workload instances.  Some will be on the same node, some on others"
SendMessageToCI "kubectl scale --replicas=4 deploy/pvc-volume-dep" "Kubectl command:" "Command"
kubectl scale --replicas=4 deploy/pvc-volume-dep

DisplayStep "Observe how some Pods are running while others remain pending"
DisplayStep "Next Step - Increases workload instances again.  Some will be on the same node, some on others"
SendMessageToCI "kubectl scale --replicas=9 deploy/pvc-volume-dep" "Kubectl command:" "Command"
kubectl scale --replicas=9 deploy/pvc-volume-dep

DisplayStep "Observe how more Pods are running while new others remain pending"
DisplayStep "Navigate to the Nodes page"
DisplayStep "Explain that this behavior is the result of AccessMode=ReadWriteOnce"

CleanUp