function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete deploy blue-dep" "Kubectl command:" "Command"
    kubectl delete deploy blue-dep
    SendMessageToCI "kubectl delete deploy green-dep" "Kubectl command:" "Command"
    kubectl delete deploy green-dep
    SendMessageToCI "kubectl delete svc/staging-svc svc/production-svc" "Kubectl command:" "Command"
    kubectl delete svc/production-svc
    ExitScript
}

# Can test service in cluster (in a separate pod)
# while sleep 1;do curl -s http://production-svc:8080 | grep -i "POD IP:"; done
# Can test service from public IP
# while sleep 1;do curl -s http://52.191.226.207:8080 | grep -i "POD IP:"; done

# Change to the demo folder
Set-Location BlueGreenDeployments
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Next Step - Creates initial blue workload and service"
SendMessageToCI "kubectl apply -f blue-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f blue-dep.yaml
SendMessageToCI "kubectl apply -f production-svc-blue.yaml" "Kubectl command:" "Command"
SendMessageToCI "selector:\n  target: blue-dep" "Original Service YAML:" "Code"
kubectl apply -f production-svc-blue.yaml

DisplayStep "Open the Services page"
DisplayStep "Wait until the load balancer is created then open a browser to the external IP/port"
DisplayStep "Notice the Blue image"
DisplayStep "Keep the browser page open"

DisplayStep "Next Step - Creates new green workload"
SendMessageToCI "kubectl apply -f green-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f green-dep.yaml

DisplayStep "Next Step - Switches the service to new workload"
SendMessageToCI "selector:\n  target: green-dep" "Service YAML Changes:" "Code"
kubectl apply -f production-svc-green.yaml

DisplayStep "Open to the external IP/Port browser page.  "
DisplayStep "Notice the image is still blue (allowing the current session to end)"
DisplayStep "Open a different browser (like Firefox) and go to the external IP/Port page"
DisplayStep "Notice the green image"

DisplayStep "Next Step - Deletes blue workload"
SendMessageToCI "kubectl delete deploy blue-dep" "Kubectl command:" "Command"
kubectl delete deploy blue-dep

CleanUp