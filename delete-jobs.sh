#!/bin/bash

# Variables
namespace="dcgm-exporter"

for job in $(kubectl get jobs -n $namespace -o custom-columns=:.metadata.name)
do
    kubectl delete jobs $job -n $namespace
done