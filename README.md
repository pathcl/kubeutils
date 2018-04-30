# kubeutils
Be warned! do not use it for production clusters.

In the happy ending it will bootstrap a k8s cluster on GKE featuring Prometheus + Grafana.

## Usage

- Create cluster
```
    $ git clone https://github.com/pathcl/kubeutils.git
    $ make 
```
- Delete cluster:
```
    $ make uninstall
```