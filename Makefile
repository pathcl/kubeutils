#TODO: 
#
# Check k8s cluster
# 	> kubectl
# 	> helm
# FIX rbac
# 	kubectl create -f rbac/cluster-reader-role.yaml
# Timing
# Logging
# Exceptions
# Grafana passwd
# KISS
# Learn Make!
# 
install:
	kubectl create clusterrolebinding bofh --clusterrole=cluster-admin --user=`gcloud auth list --filter=status:ACTIVE --format="value(account)"`
	kubectl create clusterrolebinding prometheus --clusterrole=cluster-admin --serviceaccount=default:default
	kubectl create -f prometheus/prometheus-config-map.yaml
	kubectl create -f prometheus/prometheus-deployment.yaml
	kubectl create -f prometheus/prometheus-svc.yaml
	kubectl create serviceaccount --namespace kube-system tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	helm init
	sleep 15
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
	sleep 20
	helm install --name grafana stable/grafana --set server.image=grafana/grafana:5.0.4
	kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
	sleep 20
	kubectl --namespace default port-forward `kubectl --no-headers=true get po -l app=grafana|cut -f1 -d' '` 3000
