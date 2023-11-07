function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy -l app=demo" "Kubectl command:" "Command"
    kubectl delete -f mt3chained-pdb.yaml
    ExitScript
}

# Change to the demo folder
Set-Location .\PDB
. "..\..\CISendMessage.ps1"

StartScript
SendMessageToCI "The following demo illustrates how to use PodDisruptionBudgets" "PodDisruptionBudgets:" "Info"

DisplayStep "Deploy the mt3chained application, separately from PDB"

DisplayStep "Create a PodDisruptionBudget"
kubectl apply -f mt3chained-pdb.yaml

DisplayStep "Wait until PodDisruptionBudget is configured"
kubectl describe pdb mt3chained-pdb

DisplayStep "Identify the node(s) the application is running on"
$ns = 'chained'
kubectl get pods -n $ns -o wide

DisplayStep "Drain the desired node"
$nodeName = '' # "<node-name>"
kubectl get pods --field-selector spec.nodeName=$nodeName -n $ns
kubectl drain $nodeName --ignore-daemonsets # --dry-run

DisplayStep "Perform maintenance work on the node: upgrades, patches etc., then bring back the node"
kubectl uncordon $nodeName

DisplayStep "Wait until the node is ready and see it is back scheduling pods"
kubectl get pods --field-selector spec.nodeName=$nodeName -A -n $ns

DisplayStep "Get node pool possible upgrades"
$rgName = 'k8s-tech-brief-rg'
$aksName = 'ktb-aks'
$nodePool = 'nodepool2'
az aks nodepool show --nodepool-name $nodePool --cluster-name $aksName --resource-group $rgName
az aks nodepool get-upgrades --nodepool-name $nodePool --cluster-name $aksName --resource-group $rgName

DisplayStep "Upgrade node pool"
az aks nodepool upgrade --resource-group $rgName --cluster-name $aksName --name $nodePool --node-image-only

CleanUp
