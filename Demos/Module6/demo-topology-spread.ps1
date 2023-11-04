# WASN'T WORKING BECAUSE ONE NODE WAS IN BAD STATE (VM COULDN'T GET UPDATED)

function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy workload" "Kubectl command:" "Command"
    kubectl delete deploy workload
    ExitScript
}

# Change to the demo folder
Set-Location TopologySpread
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "This demo assumes you have 3 nodes"
DisplayStep "Navigate to the Settings page.  Turn on Micro Pods"
DisplayStep "Navigate to the Nodes page"
SendMessageToCI "The following demo illustrates Pod Topology Spread Constraints" "Topology Spread:" "Info"

DisplayStep "Next Step - Create the initial workflow with 3 replicas"
SendMessageToCI "kubectl apply -f workload.yaml" "Kubectl command:" "Command"
kubectl apply -f workload.yaml
DisplayStep "Notice how Pods are evenly spread out across the nodes"

DisplayStep "Next Step - Increases workload to 12 instances"
SendMessageToCI "kubectl scale --replicas=12 deploy/workload" "Kubectl command:" "Command"
kubectl scale --replicas=12 deploy/workload
DisplayStep "Notice how Pods are still being evenly spread out across the nodes"

DisplayStep "Next Step - Increases workload to 22 instances"
SendMessageToCI "kubectl scale --replicas=22 deploy/workload" "Kubectl command:" "Command"
kubectl scale --replicas=22 deploy/workload
DisplayStep "Notice how Pods are still being evenly spread out WITHOUT exceeing MaxSkew"

DisplayStep "Next Step - Decrease workload instances again"
SendMessageToCI "kubectl scale --replicas=6 deploy/workload" "Kubectl command:" "Command"
kubectl scale --replicas=6 deploy/workload
DisplayStep "Notice how Pods may NOT be deleted evenly between the nodes"
DisplayStep "This constraint only works during scheduling, not deletions."

DisplayStep "Next Step - Increases workload to 45 instances, which is more than 3 nodes can support"
SendMessageToCI "kubectl scale --replicas=45 deploy/workload" "Kubectl command:" "Command"
kubectl scale --replicas=45 deploy/workload
DisplayStep "The auto scaler should start creating additional nodes"
DisplayStep "Notice how some Pods are still pending but there's still room on some nodes"
DisplayStep "This is because MaxSkew is set to 1, so there can be no more than 1 pod count difference between nodes"
DisplayStep "Remaining Pods will be scheduled on new node, even though there will"
DisplayStep "be a difference higher than MaxSkew.  It will NOT rebalance the Nodes."
DisplayStep "Some Pods may stay Pending, even though there's room on some of the Nodes."
DisplayStep "Again this is because of MaxSkew"

DisplayStep "Next Step - Set MaxSkew to 3 and patch the deployment"
SendMessageToCI "kubectl patch deploy workload --patch-file patch-maxskew-3.yaml" "Kubectl command:" "Command"
kubectl patch deploy workload --patch-file patch-maxskew-3.yaml
DisplayStep "The scheduler will now redeploy the pods (new replica set) and allow a difference of 3 Pods between nodes"

DisplayStep "Next Step - Set MaxSkew to 1, WhenUnsatisfiable to ScheduleAnyway.  Patch the deployment"
SendMessageToCI "kubectl patch deploy workload --patch-file patch-schedule-anyway.yaml" "Kubectl command:" "Command"
kubectl patch deploy workload --patch-file patch-schedule-anyway.yaml
DisplayStep "The scheduler will now redeploy the pods and allow all Pods to be scheduled regardless of MaxSkew"
DisplayStep "This setting is not very different from not having any constraints at all"

CleanUp