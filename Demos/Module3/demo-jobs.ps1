function CleanUp ([string] $done) {
    StartCleanUp $done
    SendMessageToCI "kubectl delete job countdown-job" "Kubectl command:" "Command"
    kubectl delete job countdown-job
    SendMessageToCI "kubectl delete cronjob sample-cron-job" "Kubectl command:" "Command"
    kubectl delete cronjob sample-cron-job
    ExitScript
}

# Change to the demo folder
Set-Location Jobs
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Jobs page"
SendMessageToCI "The following demo illustrates how Jobs and CronJobs work in Kubernetes" "Jobs and Cron Jobs:" "Info"

DisplayStep "Next Step - Creates a Job"
SendMessageToCI "kubectl apply -f countdown-job.yaml" "Kubectl command:" "Command"
kubectl apply -f countdown-job.yaml

DisplayStep "Next Step - Create a Cron Job"
SendMessageToCI "kubectl apply -f sample-cron-job.yaml" "Kubectl command:" "Command"
kubectl apply -f sample-cron-job.yaml
kubectl delete -f sample-cron-job.yaml

DisplayStep "Click on the Cron Jobs tab.  Wait for new jobs to show up.  Will maintain history of past 3 jobs"

CleanUp