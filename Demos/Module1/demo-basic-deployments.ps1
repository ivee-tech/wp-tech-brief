function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy workload-1-dep" "Kubectl command:" "Command"
    kubectl delete deploy workload-1-dep 
    ExitScript
}

# Change to the demo folder
Set-Location BasicDeployments
. "..\..\CISendMessage.ps1"

StartScript
read-host "Navigate to the Deployments page"
SendMessageToCI "The following demo illustrates the basic Kubernetes deployments" "Basic Deployments:" "Info"

DisplayStep "Next Step - Creates initial deployments"
SendMessageToCI "kubectl apply -f workload-1-dep-lime.yaml --record" "Kubectl command:" "Command"
kubectl apply -f workload-1-dep-lime.yaml --record

DisplayStep "Next Step - Updates the deployment to trigger a new replica set"
SendMessageToCI "labels:\n  color: yellow" "Deployment YAML Changes:" "Code"
kubectl apply -f workload-1-dep-yellow.yaml --record

DisplayStep "Next Step - Updates the deployment again, adding minReadySeconds"
SendMessageToCI "spec:\n  minReadySeconds: 15" "Deployment YAML Changes:" "Code"
SendMessageToCI "labels:\n  color: maroon" "Deployment YAML Changes:" "Code"
kubectl apply -f workload-1-dep-maroon.yaml --record

DisplayStep "Observe and explain toolbar buttons"
DisplayStep  "Next Step - Undoes rollout to bring previous replica set back"
SendMessageToCI "kubectl rollout undo deploy workload-1-dep" "Kubectl command:" "Command"
kubectl rollout undo deploy workload-1-dep

DisplayStep "Next Step - Changes color label to trigger a new replica set"
SendMessageToCI "labels:\n  color: pink" "Deployment YAML Changes:" "Code"
kubectl apply -f workload-1-dep-pink.yaml --record

DisplayStep "Open the Deployment Info Panel by clicking the Info (i) icon to the right of the deployment name"
DisplayStep "Next Step - Changes color label and INVALID image.  See what happenes with the new replica set"
SendMessageToCI "containers:\n- image: nginx:1.12345" "Deployment YAML Changes:" "Code"
kubectl apply -f workload-1-dep-aqua-invalid.yaml --record

DisplayStep "Next Step - Undoes rollout to previous replica set"
SendMessageToCI "kubectl rollout undo deploy workload-1-dep" "Kubectl command:" "Command"
kubectl rollout undo deploy workload-1-dep

DisplayStep "Next Step - Undoes rollout back to Rev 1"
SendMessageToCI "kubectl rollout undo deploy workload-1-dep --to-revision=1" "Kubectl command:" "Command"
kubectl rollout undo deploy workload-1-dep --to-revision=1

DisplayStep "Next Step - Changes deployment strategy to Recreate"
SendMessageToCI "strategy:\n  type: Recreate" "Deployment YAML Changes:" "Code"
kubectl apply -f workload-1-dep-blue-recreate.yaml

DisplayStep "Next Step - Changes deployment strategy to Rolling Update and sets Revision History"
SendMessageToCI "strategy:\n  type: RollingUpdate\nrevisionHistoryLimit: 2" "Deployment YAML Changes:" "Code"
kubectl apply -f workload-1-dep-orange-revision-history.yaml

CleanUp 