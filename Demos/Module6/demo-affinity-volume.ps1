function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy pvc-pod-dep" "Kubectl command:" "Command"
    kubectl delete deploy pvc-pod-dep
    ExitScript
}

# Change to the demo folder
Set-Location AffinityVolume
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page.  Turn on Mini Pods"
DisplayStep "Navigate to the Nodes page"
SendMessageToCI "The following demo illustrates Pod Affinity used to ensure all replicas are scheduled on the same node" "Pod Affinity:" "Info"

DisplayStep "Next Step - Creates PVC and Deployment with 6 replicas.  All will be on same node"
SendMessageToCI "kubectl apply -f pvc.yaml -f pvc-dep-replicas-6.yaml" "Kubectl command:" "Command"
kubectl apply -f pvc.yaml
kubectl apply -f pvc-dep-replicas-6.yaml

DisplayStep "Next Step - Increases workload instances.  All still on same node"
SendMessageToCI "kubectl scale --replicas=12 deploy/pvc-pod-dep" "Kubectl command:" "Command"
kubectl scale --replicas=12 deploy/pvc-pod-dep

DisplayStep "Next Step - Increases workload instances past limit.  Some will remain Pending even if there's room on other nodes"
SendMessageToCI "kubectl scale --replicas=24 deploy/pvc-pod-dep" "Kubectl command:" "Command"
kubectl scale --replicas=24 deploy/pvc-pod-dep

DisplayStep "Next Step - Change the Affinity rule to Preferred.  Pending pods will be scheduled on other nodes"
SendMessageToCI "podAffinity:\n  preferredDuringSchedulingIgnoredDuringExecution:\n    - weight: 100" "Deployment YAML Changes:" "Code"
kubectl apply -f pvc-dep-replicas-24-preferred.yaml

DisplayStep "Notice that new pods can't start because the volume has already been attached to the other node"

CleanUp