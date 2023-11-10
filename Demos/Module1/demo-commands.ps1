# https://github.com/dgkanatsios/CKAD-exercises

## a - Core Concepts

kubectl config current-context

kubectl get ns # namespace 
kubectl create namespace ns1
# kubectl delete ns ns1
kubectl get ns ns1

kubectl run -it --rm nginx01 --image=nginx --restart=Never -n ns1

kubectl get pods -n ns1 --show-labels
kubectl get pod nginx01 -n ns1 -o wide
kubectl get pod nginx01 -n ns1 -o yaml > nginx01.yaml

kubectl describe po nginx01 -n ns1

kubectl logs nginx01 -n ns1
kubectl delete po nginx01 -n ns1

kubectl explain pod.spec.containers.image



kubectl delete pod bb001 -n ns1

kubectl label pod nginx01 app=myapp -n ns1
kubectl get pods -n ns1 --selector=app=myapp --show-labels

kubectl label pods nginx01 app- -n ns1

kubectl run nginx01 --image=nginx --restart=Never -n mynamespace --dry-run=client -o yaml > nginx01.yaml
cat nginx01.yaml
kubectl apply -f .\nginx01.yaml

kubectl run -it --rm busybox001 --image=busybox --restart=Never -n mynamespace -- env

kubectl run busybox001 --image=busybox --restart=Never -n mynamespace --command -o yaml --dry-run=client  -- env > busybox001.yaml

kubectl create -f .\busybox001.yaml 
kubectl describe pod busybox001 -n mynamespace 
kubectl logs busybox001 -n $ns

kubectl create namespace myns --dry-run=client -o yaml > myns.yaml

kubectl create resourcequota myrq --hard='cpu=1,memory=1G,pods=2' --dry-run=client -o yaml

kubectl get pods --all-namespaces

kubectl run nginx001 --image=nginx --port=80 --restart=Never

kubectl set image pods/nginx001 nginx001=nginx:1.7.1
kubectl describe pod nginx001
kubectl get pod nginx001 -w

kubectl get pod nginx001 -o wide # returns smth similar to 172.17.0.3
kubectl run -it --rm bb001 --image=busybox --restart=Never -- wget -O- 172.17.0.3:80

$NGINX_IP=$(kubectl get pod nginx001 -o jsonpath='{.status.podIP}')
kubectl run -it --rm bb001 --image=busybox --restart=Never --env=NGINX_IP=$NGINX_IP -- sh -c 'wget -O- $NGINX_IP:80'

kubectl get pod nginx001 -o yaml
kubectl get pod nginx001 --output=yaml

kubectl describe pod nginx001

kubectl logs nginx001

kubectl logs nginx001 --previous
kubectl logs nginx001 -p

kubectl exec -it nginx -- /bin/sh

kubectl run -it bb002 --image=busybox --restart=Never -- echo 'Hello World'
kubectl run -it --rm bb003 --image=busybox --restart=Never -- echo 'Hello World'

kubectl run nginx --image=nginx --restart=Never --env=var1=val1
# then
kubectl exec -it nginx -- env
# or
kubectl exec -it nginx -- sh -c 'echo $var1'
# or
kubectl describe po nginx | grep val1
# or
kubectl run nginx --restart=Never --image=nginx --env=var1=val1 -it --rm -- env


kubectl get nodes --show-labels
$node = 'aks-nodepool1-33785009-vmss00001n'
kubectl label node $node app=myapp
kubectl get node $node --show-labels
