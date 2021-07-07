
#!/bin/bash

# For more information, see https://github.com/kubernetes-sigs/prometheus-adapter 
namespace="prometheus-adapter"
repoName="prometheus-community"
repoUrl="https://prometheus-community.github.io/helm-charts"
chartName="prometheus-adapter"
releaseName="prometheus-adapter"

# check if namespace exists in the cluster
result=$(kubectl get ns -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "$namespace namespace already exists in the cluster"
else
    echo "$namespace namespace does not exist in the cluster"
    echo "creating $namespace namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Check if the repository is not already added
result=$(helm repo list | grep $repoName | awk '{print $1}')

if [[ -n $result ]]; then
    echo "[$repoName] Helm repo already exists"
else
    # Add the Jetstack Helm repository
    echo "Adding [$repoName] Helm repo..."
    helm repo add $repoName $repoUrl
fi

# Update your local Helm chart repository cache
echo 'Updating Helm repos...'
helm repo update

# Install Helm chart
result=$(helm list -n $namespace | grep $releaseName | awk '{print $1}')

if [[ -n $result ]]; then
    echo "[$releaseName] already exists in the [$namespace] namespace"
else
    # Install the Helm chart
    echo "Deploying [$releaseName] to the [$namespace] namespace..."
    helm install $releaseName $repoName/$chartName \
        --namespace $namespace \
        --set rbac.create=true \
        --set prometheus.url=http://kube-prometheus-stack-prometheus.kube-prometheus-stack.svc.cluster.local \
        --set prometheus.port=9090
fi

# List pods
kubectl get pods -n $namespace -o wide

# After a a few minutes you should be able to list metrics using the following command(s):
# kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1
# Use https://grafana.com/grafana/dashboards/12239 grafana dashboard to see GPU metrics
