function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy -l app=demo" "Kubectl command:" "Command"
    kubectl delete deploy -l app=demo
    SendMessageToCI "kubectl delete service probe-svc" "Kubectl command:" "Command"
    kubectl delete service probes-svc
    ExitScript
}

# Change to the demo folder
Set-Location Probes
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page"
DisplayStep "Turn OFF Mini and Micro Pods"
DisplayStep "Turn ON Show Containers"
DisplayStep "Navigate to the Namespace"
SendMessageToCI "The following demo illustrates how different Probes work and how they effect Services" "Probes:" "Info"

DisplayStep "Next Step - Creates a Startup Probes"
SendMessageToCI "kubectl apply -f probes-svc.yaml" "Kubectl command:" "Command"
kubectl apply -f probes-svc.yaml
SendMessageToCI "kubectl apply -f dep-startup-probe.yaml" "Kubectl command:" "Command"
kubectl apply -f dep-startup-probe.yaml

DisplayStep "Review how the Pod never reaches a Ready state even though it's Running"
DisplayStep "Wait a minute or two and see the how the Restart count increases"
DisplayStep "Navigate to the Services and see how it's not available"

DisplayStep "Navigate to the Namespace"
DisplayStep "Next Step - Create a Liveness Probe"
SendMessageToCI "kubectl apply -f dep-liveness-probe.yaml" "Kubectl command:" "Command"
kubectl apply -f dep-liveness-probe.yaml

DisplayStep "After the Pod is ready, navigate to the Services and see how it's available"
DisplayStep "Wait for a minute or two.  See how it restarts the container, but it stays available"

DisplayStep "Navigate to the Namespace"
DisplayStep "Next Step - Create a Readiness Probe"
SendMessageToCI "kubectl apply -f dep-readiness-probe.yaml" "Kubectl command:" "Command"
kubectl apply -f dep-readiness-probe.yaml

DisplayStep "Navigate to the Services and see how it's not available for about a minute then shows up"

CleanUp