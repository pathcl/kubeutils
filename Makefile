prometheus:
	kubectl create -f prometheus-config-map.yaml
	kubectl create -f prometheus-deployment.yaml
	helm install --name grafana stable/grafana --set server.image=grafana/grafana:5.0.4
helm:

