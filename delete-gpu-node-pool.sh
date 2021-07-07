#!/bin/bash

nodePoolName="gpu"
aksClusterName="YOUR-AKS-CLUSTER-NAME"
resourceGroupName="YOUR-AKS-RESOURCE-GROUP-NAME"
vmSize="Standard_NC6"
nodeCount=1
aksCustomHeaders="UseGPUDedicatedVHD=true"
taints="sku=gpu:NoSchedule"
labels="cputype=gpu"

az aks nodepool show \
    --name $nodePoolName \
    --cluster-name $aksClusterName \
    --resource-group $resourceGroupName &>/dev/null

if [[ $? == 0 ]]; then
    echo "A node pool called [$nodePoolName] already exists in the [$aksClusterName] AKS cluster"
    az aks nodepool delete \
        --name $nodePoolName \
        --cluster-name $aksClusterName \
        --resource-group $resourceGroupName 1>/dev/null

    if [[ $? == 0 ]]; then
        echo "[$nodePoolName] node pool successfully deleted in the [$aksClusterName] AKS cluster"
    else
        echo "Failed to delete the [$nodePoolName] node pool in the [$aksClusterName] AKS cluster"
    fi
else
    echo "No node pool called [$nodePoolName] actually exists in the [$aksClusterName] AKS cluster"
fi
