function CleanUp ([string] $done) {
    StartCleanUp $done    
    Stop-Job -Name rabbit
    Remove-Job -Name rabbit
    kubectl delete -f .
    ExitScript
}

# Change to the demo folder
Set-Location KEDA-RabbitMQ
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page"
DisplayStep "Turn ON Micro Pods"
DisplayStep "Navigate to the Deployments page"

DisplayStep "Next Step - Creates initial workloads"
kubectl apply -f rabbit-cm.yaml
kubectl apply -f rabbit-dep.yaml
kubectl apply -f rabbit-svc.yaml
kubectl apply -f queue-processor.yaml

DisplayStep "Wait until Rabbit workload is ready"

DisplayStep "Load rabbit UI - In a background job"
Start-Job -Name rabbit -ScriptBlock { kubectl port-forward svc/rabbit-svc 15672 } 

DisplayStep "Open a browser window and navigate to http://localhost:15672"
DisplayStep "Observer SampleQueue on the Queues page"

DisplayStep "Next Step - Loads Messages into queue"
kubectl apply -f queue-loader-job.yaml

DisplayStep "Observer about 500 message in SampleQueue on the Queues page"
DisplayStep "Observer how slowly they're being processed"

DisplayStep "Next Step - Creates KEDA autoscaler"
kubectl apply -f keda-rabbit.yaml

DisplayStep "Observer increase in pod replicas.  Show HPA Info (i) panel.  Observe Scale Down Stabilization Window"
DisplayStep "Observer pod replica decrease as queued messages decrease"

CleanUp