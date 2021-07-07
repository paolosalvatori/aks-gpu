#!/bin/bash

# For more information, see https://docs.nvidia.com/datacenter/cloud-native/kubernetes/dcgme2e.html 
# Also look at https://github.com/NVIDIA/gpu-monitoring-tools/blob/master/etc/dcgm-exporter/default-counters.csv for metrics
namespace="dcgm-exporter"
repoName="gpu-helm-charts"
repoUrl="https://nvidia.github.io/gpu-monitoring-tools/helm-charts"
chartName="dcgm-exporter"
releaseName="dcgm-exporter"

# Check if namespace exists in the cluster
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
        --values values.yaml
fi

# List pods
kubectl get pods -n $namespace -o wide