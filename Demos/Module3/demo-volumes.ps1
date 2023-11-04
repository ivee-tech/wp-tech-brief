function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy workload-1-ephemeral workload-3-dynamic-file" "Kubectl command:" "Command"
    kubectl delete deploy workload-1-ephemeral workload-3-dynamic-file
    SendMessageToCI "kubectl delete deploy workload-2-disk" "Kubectl command:" "Command"
    kubectl delete deploy workload-2-disk
    SendMessageToCI "kubectl delete cm configmap-file" "Kubectl command:" "Command"
    kubectl delete cm configmap-file
    SendMessageToCI "kubectl delete secret secret-simple" "Kubectl command:" "Command"
    kubectl delete secret secret-simple
    SendMessageToCI "kubectl delete pvc dynamic-file-storage-pvc" "Kubectl command:" "Command"
    kubectl delete pvc dynamic-file-storage-pvc
    ExitScript
}


# Change to the demo folder
Set-Location volumes
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Namespace"
SendMessageToCI "The following demo illustrates different types of Volumes in Kubernetes" "Volumes:" "Info"

DisplayStep "Next Step - Create initial workload with ephemeral volumes"
SendMessageToCI "kubectl apply -f configmap-file.yaml" "Kubectl command:" "Command"
SendMessageToCI "kubectl apply -f secret-simple.yaml" "Kubectl command:" "Command"
kubectl apply -f configmap-file.yaml 
kubectl apply -f secret-simple.yaml
SendMessageToCI "kubectl apply -f workload-1-ephemeral.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-1-ephemeral.yaml

$AzureDiskName = DisplayStep "Enter the Disk Name of the Azure Disk (make sure the cluster identity has rights to disk)" 
$AzureDiskUri = DisplayStep "Enter the Resource ID of the Azure Disk" 
$AzureDiskName
$AzureDiskUri
if (($AzureDiskName) -and ($AzureDiskUri)) {
    SendMessageToCI "Save the name of the Resource ID of an existing Azure Disk" "Save Azure Disk:" "Info"
    Copy-Item workload-2-disk.yaml temp-disk.yaml
    (Get-Content -path temp-disk.yaml -Raw) -replace 'AZURE_DISK_NAME', $AzureDiskName | Set-Content -Path temp-disk.yaml
    (Get-Content -path temp-disk.yaml -Raw) -replace 'AZURE_DISK_URI', $AzureDiskUri | Set-Content -Path temp-disk.yaml
    DisplayStep "Next Step - Create deployment with Azure Disk Volume"
    SendMessageToCI "kubectl apply -f workload-2-disk.yaml" "Kubectl command:" "Command"
    kubectl apply -f temp-disk.yaml 
    Remove-Item temp-disk.yaml
}

# kubectl delete deploy workload-2-disk


DisplayStep "Next Step - Create deployment with Dynamic Azure File Volume"
SendMessageToCI "kubectl apply -f pvc-dynamic-file.yaml" "Kubectl command:" "Command"
kubectl apply -f pvc-dynamic-file.yaml
SendMessageToCI "kubectl apply -f workload-3-dynamic-file.yaml" "Kubectl command:" "Command"
kubectl apply -f workload-3-dynamic-file.yaml

CleanUp