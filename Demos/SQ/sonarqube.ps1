kubectl get nodes

# add taint and label to the node running SQ
$nodeName = 'aks-nodepool2-23264799-vmss000003'
kubectl taint nodes $nodeName sonarqube=true:NoSchedule
# kubectl taint nodes $nodeName sonarqube=true:NoSchedule-
kubectl label node $nodeName sonarqube=true
# kubectl label node $nodeName sonarqube-

# install SQ
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create namespace sonarqube
helm upgrade -f .\values.yaml --install -n sonarqube sonarqube sonarqube/sonarqube
# helm uninstall sonarqube -n sonarqube


# verify deployment
kubectl get pods -n sonarqube

# get service and public IP
kubectl get services -n sonarqube
# OR
$SERVICE_IP=$(kubectl get svc --namespace sonarqube sonarqube-sonarqube -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
Write-Output http://$($SERVICE_IP):9000

# http://20.213.170.182:9000/


# run in the solution folder

# begin
C:\tools\sonar-scanner\netfx\SonarScanner.MSBuild.exe begin /k:"dawr-demo_WebAppLegacyDemo_AYac7L3sgr-BSwOVNtES" /d:sonar.host.url="http://20.213.170.182:9000" /d:sonar.login="sqp_4797aa61aa968f73285d71759b0d233e1f3b5626"

# build
& "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MsBuild.exe" /t:Rebuild

#end
c:\tools\sonar-scanner\netfx\SonarScanner.MSBuild.exe end /d:sonar.login="sqp_4797aa61aa968f73285d71759b0d233e1f3b5626"
