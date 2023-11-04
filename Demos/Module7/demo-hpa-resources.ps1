function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete svc complex-web-svc" "Kubectl command:" "Command"
    kubectl delete svc complex-web-svc
    SendMessageToCI "kubectl delete deploy complex-web-dep" "Kubectl command:" "Command"
    kubectl delete deploy complex-web-dep
    SendMessageToCI "kubectl delete deploy complex-web-load" "Kubectl command:" "Command"
    kubectl delete deploy complex-web-load
    SendMessageToCI "kubectl delete hpa complex-web-hpa-1" "Kubectl command:" "Command"
    kubectl delete hpa complex-web-hpa-1
    ExitScript
}

# Change to the demo folder
Set-Location HPA
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page"
DisplayStep "Turn off Mini/Micro Pods so Full sized pods are shown"
DisplayStep "Turn ON Show Pod Resources"
DisplayStep "Navigate to the Deployments page"
SendMessageToCI "The following demo illustrates how the Horizontal Pod Autoscaler works in Kubernetes" "Horizontal Scaling:" "Info"

DisplayStep "Next Step - Creates initial workload"
SendMessageToCI "kubectl apply -f complex-web-dep.yaml -f complex-web-svc.yaml" "Kubectl command:" "Command"
kubectl apply -f complex-web-dep.yaml -f complex-web-svc.yaml

DisplayStep "Wait for Current Metrics to appear in each pod"

DisplayStep "Next Step - Creates load workload"
SendMessageToCI "kubectl apply -f complex-web-load.yaml" "Kubectl command:" "Command"
kubectl apply -f complex-web-load.yaml

DisplayStep "Wait for Current Metrics to increase in each pod"

DisplayStep "Next Step - Increase load instances"
SendMessageToCI "kubectl scale --replicas=6 deploy/complex-web-load" "Kubectl command:" "Command"
kubectl scale --replicas=6 deploy/complex-web-load

DisplayStep "Optional - Wait for Current Metrics to increase even more in each pod"

DisplayStep "Next Step - Creates Horizontal Pod Autoscaler"
SendMessageToCI "kubectl apply -f complex-web-hpa.yaml" "Kubectl command:" "Command"
kubectl apply -f complex-web-hpa.yaml

DisplayStep "Click on the Info (i) icon in the HPA to show Behaviors"
DisplayStep "Wait for number of pods to stabalize"

DisplayStep "Next Step - Decrease load instances"
SendMessageToCI "kubectl scale --replicas=1 deploy/complex-web-load" "Kubectl command:" "Command"
kubectl scale --replicas=1 deploy/complex-web-load

DisplayStep "Wait for number of pods to decrease"

DisplayStep "Next Step - Delete load instances"
SendMessageToCI "kubectl delete deploy complex-web-load" "Kubectl command:" "Command"
kubectl delete deploy complex-web-load

DisplayStep "Wait for number of pods to decrease down to 2.  Notice the orignal number of instances was 3"

DisplayStep "Next Step - Add another metric to HPA to show it can support more than one"
SendMessageToCI "- type: Resource\n  resource:\n    name: memory\n    target:\n      type: Utilization\n      averageUtilization: 50" "Deployment YAML Changes:" "Code"
SendMessageToCI "kubectl apply -f complex-web-hpa2.yaml" "Kubectl command:" "Command"
kubectl apply -f complex-web-hpa2.yaml

CleanUp