#!/bin/bash

namespace="gpu-resources"
daemonset="nvidia-device-plugin-daemonset"

# Check if the namespace exists in the cluster
result=$(kubectl get ns -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "$namespace namespace already exists in the cluster"
else
    echo "$namespace namespace does not exist in the cluster"
    echo "creating $namespace namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Check if the daemonset exists
result=$(kubectl get ds -n $namespace -o jsonpath="{.items[?(@.metadata.name=='$daemonset')].metadata.name}")

if [[ -n $result ]]; then
    echo "$daemonset daemonset already exists in the $namespace namespace"
    echo "deleting $daemonset daemonset from the $namespace namespace..."
    kubectl delete ds $daemonset -n $namespace 
else
    echo "$daemonset daemonset does not exist in the $namespace namespace"
fi

# Create the daemonset
echo "creating $daemonset daemonset in the $namespace namespace..."
kubectl apply -f nvidia-device-plugin-ds.yaml