function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy -l scope=demo" "Kubectl command:" "Command"
    kubectl delete deploy -l scope=demo
    SendMessageToCI "kubectl label node $($selectedNode) color-" "Kubectl command:" "Command"
    kubectl label node $selectedNode color-
    SendMessageToCI "kubectl label node $($selectedNode) allowedprocess-" "Kubectl command:" "Command"
    kubectl label node $selectedNode allowedprocess-
    SendMessageToCI "kubectl taint node $($selectedNode) onlyprocess-" "Kubectl command:" "Command"
    kubectl taint node $selectedNode onlyprocess-
    ExitScript
}

# Change to the demo folder
Set-Location TaintsTolerations
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page"
DisplayStep "Turn ON Mini or Micro Pods"
DisplayStep "Navigate to the Nodes page"
SendMessageToCI "The following demo illustrates how Taints and Tolerations work in Kubernetes" "Taints and Tolerations:" "Info"

DisplayStep "Next Step - Creates initial workloads"
SendMessageToCI "kubectl apply -f workload-1.yaml -f workload-2.yaml -f workload-3.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-1.yaml -f workload-2.yaml -f workload-3.yaml

$selectedNode = read-host "Enter the Node Name of one node" 
SendMessageToCI "Save the name of the primary node" "Save Node Name:" "Info"

DisplayStep "Next Step - Adds color and Process label to Node"
SendMessageToCI "kubectl label node $($selectedNode) color=lime --overwrite" "Kubectl command:" "Command"
kubectl label node $selectedNode color=lime --overwrite
SendMessageToCI "kubectl label node $($selectedNode) allowedprocess=gpu --overwrite" "Kubectl command:" "Command"
kubectl label node $selectedNode allowedprocess=gpu --overwrite

DisplayStep "Notice the color box appear in the Node"

DisplayStep "Next Step - Adds Node Selector to Lime deployment"
SendMessageToCI "kubectl apply -f workload-1-node-selector.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-1-node-selector.yaml

DisplayStep "Wait for all the Lime pods to be rescheduled on the selected node"

DisplayStep "Next Step - Adds Taint to Node"
SendMessageToCI "kubectl taint node $($selectedNode) onlyprocess=gpu:NoSchedule" "Kubectl command:" "Command"
kubectl taint node $selectedNode onlyprocess=gpu:NoSchedule

DisplayStep "Delete all the Pods on the Node"
SendMessageToCI "Delete current workload to make the Scheduler reallocate them on different Nodes" "Delete Current Pods:" "Info"
SendMessageToCI "kubectl delete pods --field-selector=spec.nodeName=$($selectedNode)" "Kubectl command:" "Command"
kubectl delete pods --field-selector=spec.nodeName=$selectedNode

DisplayStep "Wait for ALL pods to be evicted from selected node"

DisplayStep "Observe how Lime pods cannot be scheduled.  Examine their events"

DisplayStep "Next Step - Adds Toleration to Lime deployment"
SendMessageToCI "tolerations:\n- key: 'onlyprocess'\n  operator: 'Equal'\n  value: 'gpu'\n  effect: 'NoSchedule'" "Deployment YAML Changes:" "Code"
SendMessageToCI "kubectl apply -f workload-1-toleration.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-1-toleration.yaml

DisplayStep "Observe how only the Lime pods are scheduled on selected node and all others are on other nodes"

CleanUp