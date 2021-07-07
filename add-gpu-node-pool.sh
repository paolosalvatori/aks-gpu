#!/bin/bash

# az aks nodepool add --name gpu --cluster-name YOUR-AKS-CLUSTER-NAME --resource-group YOUR-AKS-RESOURCE-GROUP-NAME --node-vm-size Standard_NC6 --node-count 1 --aks-custom-headers UseGPUDedicatedVHD=true

nodePoolName="gpu"
aksClusterName="YOUR-AKS-CLUSTER-NAME"
resourceGroupName="YOUR-AKS-RESOURCE-GROUP-NAME"
vmSize="Standard_NC6"
nodeCount=1
minCount=1
maxCount=3
maxPods=100
taints="sku=gpu:NoSchedule"
useAksCustomHeaders="true"

az aks nodepool show \
    --name $nodePoolName \
    --cluster-name $aksClusterName \
    --resource-group $resourceGroupName &>/dev/null

if [[ $? == 0 ]]; then
    echo "A node pool called [$nodePoolName] already exists in the [$aksClusterName] AKS cluster"
else
    echo "No node pool called [$nodePoolName] actually exists in the [$aksClusterName] AKS cluster"
    echo "Creating [$nodePoolName] node pool in the [$aksClusterName] AKS cluster..."

    if [[ -z $useAksCustomHeaders ]]; then
        az aks nodepool add \
            --name $nodePoolName \
            --cluster-name $aksClusterName \
            --resource-group $resourceGroupName \
            --enable-cluster-autoscaler \
            --node-vm-size $vmSize \
            --node-count $nodeCount \
            --min-count $minCount \
            --max-count $maxCount \
            --max-pods $maxPods \
            --node-taints $taints 1>/dev/null
    else
        echo "Using [UseGPUDedicatedVHD=true] AKS custom header..."
        az aks nodepool add \
            --name $nodePoolName \
            --cluster-name $aksClusterName \
            --resource-group $resourceGroupName \
            --enable-cluster-autoscaler \
            --node-vm-size $vmSize \
            --node-count $nodeCount \
            --min-count $minCount \
            --max-count $maxCount \
            --max-pods $maxPods \
            --node-taints $taints \
            --aks-custom-headers UseGPUDedicatedVHD=true 1>/dev/null
    fi

    if [[ $? == 0 ]]; then
        echo "[$nodePoolName] node pool successfully created in the [$aksClusterName] AKS cluster"
    else
        echo "Failed to create the [$nodePoolName] node pool in the [$aksClusterName] AKS cluster"
    fi
fi
