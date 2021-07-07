#!/bin/bash

# Variables
namespace="dcgm-exporter"
template="samples-tf-mnist-demo.yaml"

# Check if namespace exists in the cluster
result=$(kubectl get ns -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "$namespace namespace already exists in the cluster"
else
    echo "$namespace namespace does not exist in the cluster"
    echo "creating $namespace namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Read the number of jobs to create from the argument
if [[ -z ${1} ]];then
    n=1
else
    n=${1}
fi

# Create job(s)
for ((i=0;i<$n;i++))
do
    postfix=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -n 1)
    name="samples-tf-mnist-demo-$postfix"
    cat $template | 
    yq -Y "(.metadata.name)|="\""$name"\" |
    yq -Y "(.metadata.labels.app)|="\""$name"\" |
    kubectl apply -n $namespace -f -
    kubectl get pods --selector app=$name $selector -n $namespace
done
