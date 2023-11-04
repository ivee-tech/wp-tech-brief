function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete statefulset/pvc-pod-ss service/pvc-pod-svc" "Kubectl command:" "Command"
    kubectl delete statefulset/pvc-pod-ss
    kubectl delete service/pvc-pod-svc
    ExitScript
}

# Change to the demo folder
Set-Location AntiAffinityStatefulSet
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page.  Turn off Mini/Micro Pods so Full sized pods are shown"
DisplayStep "Navigate to the Nodes page"
SendMessageToCI "The following demo illustrates Pod Anti-Affinity used to ensure that each replica is scheduled on a different node" "Pod Anti-Affinity:" "Info"

DisplayStep "Next Step - Creates initial workloads of Stateful Set with 2 instances"
SendMessageToCI "kubectl apply -f pvc-ss.yaml" "Kubectl command:" "Command"
kubectl apply -f pvc-ss.yaml

DisplayStep "Next Step - Increase stateful set instances"
SendMessageToCI "kubectl scale --replicas=3 statefulset/pvc-pod-ss" "Kubectl command:" "Command"
kubectl scale --replicas=3 statefulset/pvc-pod-ss

DisplayStep "Notice the events of the Pending pods.  Additional nodes are created to support them"

CleanUp
