# TODO:
# 
# > Detect OS
# > Releases
# > Error Handling

.DEFAULT_GOAL := all
SDK := $(shell gcloud config list 2> /dev/null)
KUBECTL := $(shell kubectl 2> /dev/null)
HELM := $(shell helm 2> /dev/null)

.clusterroles: ## Enable rbac for prometheus
	$(info )
	$(info +++ Kubernetes cluster up and running. Now creating roles for GKE compatiblity.)
	$(info )
	@kubectl create clusterrolebinding bofh --clusterrole=cluster-admin --user=`gcloud auth list --filter=status:ACTIVE --format="value(account)"`
	@kubectl create clusterrolebinding prometheus --clusterrole=cluster-admin --serviceaccount=default:default
	$(info )

.gke: ## Creates kubernetes cluster
	$(info )
	$(info --- Building Kubernetes cluster)
	$(info )
	@gcloud container clusters create kubelab --cluster-version 1.9 --no-user-output-enabled
	$(info )

.helm: ## Setup helm for kubernetes cluster
	$(info )
	@kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	@kubectl create serviceaccount --namespace kube-system tiller
	$(info --- Initializing Helm Package Manager)
	$(info )
	@helm init
	@sleep 15
	@kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
	@sleep 20
	$(info )

.prometheus: ## Install prometheus
	$(info )
	$(info --- Installing Prometheus)
	@kubectl create -f prometheus/prometheus-config-map.yaml
	@kubectl create -f prometheus/prometheus-deployment.yaml
	@kubectl create -f prometheus/prometheus-svc.yaml
	$(info )
	$(info +++ Prometheus installed)
	$(info )

.grafana: ## Install grafana
	$(info )
	$(info --- Deploying Grafana)
	@helm install --name grafana stable/grafana --set server.image=grafana/grafana:5.0.4
	@sleep 20
	$(info )
	$(info +++ Grafana installed)
	$(info )

.uninstall: ## Delete cluster
	$(info --- Deleting cluster)
	@gcloud container -q clusters delete kubelab --no-user-output-enabled

build: .gke .clusterroles .helm .prometheus .grafana

uninstall: .uninstall

deps: ## Checks for dependencies

ifndef KUBECTL
    $(warning "Kubectl not installed!. Installing...")
	$(shell curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl)
	$(shell chmod +x ./kubectl)
	$(shell sudo mv ./kubectl /usr/local/bin/kubectl)
endif
	$(info +++ kubectl is already installed. )

ifndef HELM
    $(warning "Helm not installed!. Installing...")
	$(shell curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash)
endif
	$(info +++ helm is already installed. )


ifndef SDK
    $(warning "Google cloud is not installed!. Installing...")
	$(shell curl https://sdk.cloud.google.com | bash)
	$(shell exec -l $SHELL)
	$(gcloud init)
endif
	$(info +++ gcloud is already installed.)
	$(info )
	$(info *** Everything in its right place.)
	$(info )

all: deps build ## Setup GKE and Prometheus+Grafana