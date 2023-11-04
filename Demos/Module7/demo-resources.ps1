function CleanUp ([string] $done) {
    StartCleanUp $done    
    SendMessageToCI "kkubectl delete deploy -l app=demo" "Kubectl command:" "Command"
    kubectl delete deploy -l app=demo
    SendMessageToCI "kubectl delete limitrange -l app=demo" "Kubectl command:" "Command"
    kubectl delete limitrange -l app=demo
    SendMessageToCI "kubectl delete resourcequota -l app=demo" "Kubectl command:" "Command"
    kubectl delete resourcequota -l app=demo
    ExitScript
}

# Change to the demo folder
Set-Location Resources
. "..\..\CISendMessage.ps1"

StartScript
DisplayStep "Navigate to the Settings page"
DisplayStep "Turn off Mini/Micro Pods so Full sized pods are shown"
DisplayStep "Turn ON Show Pod Resources"
DisplayStep "Navigate to the Namespace page"
SendMessageToCI "The following demo illustrates how Resource Limits and Requests work in Kubernetes" "Horizontal Scaling:" "Info"

DisplayStep "Next Step - Creates initial workloads"
SendMessageToCI "kubectl apply -f workload1-dep.yaml -f workload2-dep.yaml" "Kubectl command:" "Command"
SendMessageToCI "kubectl apply -f workload3-dep.yaml -f workload4-dep.yaml" "Kubectl command:" "Command"
kubectl apply -f workload1-dep.yaml -f workload2-dep.yaml -f workload3-dep.yaml -f workload4-dep.yaml

DisplayStep "Notice there are no requests or limits defined for any of the Pods"

DisplayStep "Next Step - Creates Limit Ranges"
SendMessageToCI "kubectl apply -f namespace-limit-range.yaml" "Kubectl command:" "Command"
kubectl apply -f namespace-limit-range.yaml

DisplayStep "Notice existing Pods are not changed.  You have to recreate them"
DisplayStep "Next Step - Update the images to force the Pods to be created"
SendMessageToCI "kubectl set image deploy workload1-dep nginx=nginx:1.18" "Kubectl command:" "Command"
kubectl set image deploy workload1-dep nginx=nginx:1.18
kubectl set image deploy workload2-dep nginx=nginx:1.18
kubectl set image deploy workload3-dep nginx=nginx:1.18
kubectl set image deploy workload4-dep nginx=nginx:1.18

DisplayStep "Notice new Pods have requests and limits"
DisplayStep "Next Step - Create Resource Quotas"
SendMessageToCI "kubectl set image deploy workload1-dep nginx=nginx:1.18" "Kubectl command:" "Command"
kubectl apply -f namespace-resource-quotas.yaml

DisplayStep "Next Step - Update the images to force the Pods to be created"
SendMessageToCI "kubectl set image deploy workload1-dep nginx=nginx:1.19" "Kubectl command:" "Command"
kubectl set image deploy workload1-dep nginx=nginx:1.19
kubectl set image deploy workload2-dep nginx=nginx:1.19
kubectl set image deploy workload3-dep nginx=nginx:1.19
kubectl set image deploy workload4-dep nginx=nginx:1.19

DisplayStep "Notice nothing is being upgraded/replaced.  Examine the events of the ReplicaSet.  Notice memory limits are being exceeded"


DisplayStep "Next Step - Raise the Resource Quota slightly"
kubectl apply -f namespace-resource-quotas-slight.yaml

DisplayStep "Wait a minute or two.  Notice how some of the Pods are being upgraded individually"
DisplayStep "1-2 Pods will continue to be replaced as the ReplicaSets notice there's now some room available"
DisplayStep "Notice some Pod have exceeded Quota Pods count.  Toggle between Namespace and Deployments pages to see progress"
DisplayStep "Eventually all the Pods will be upgraded, but it will take some time"

DisplayStep "Next Step - Raise the Resource Quota to double the original values"
kubectl apply -f namespace-resource-quotas-double.yaml

DisplayStep "Next Step - Update the images to force the Pods to be created"
SendMessageToCI "kubectl set image deploy workload1-dep nginx=nginx:1.20" "Kubectl command:" "Command"
# might work with for v1.19
# kubectl rollout restart deploy
kubectl set image deploy workload1-dep nginx=nginx:1.20
kubectl set image deploy workload2-dep nginx=nginx:1.20
kubectl set image deploy workload3-dep nginx=nginx:1.20
kubectl set image deploy workload4-dep nginx=nginx:1.20

DisplayStep "Notice how everyting is upgraded/replaced at the same time, because there's plenty of room for old and new Pods"

CleanUp