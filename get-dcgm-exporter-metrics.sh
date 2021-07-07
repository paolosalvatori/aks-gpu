#!/bin/bash

namespace="dcgm-exporter"
container="exporter"

pod=$(kubectl get pods -n $namespace -l app.kubernetes.io/component=dcgm-exporter -o custom-columns=:metadata.name)
kubectl exec --stdin --tty \
        -n $namespace -c $container $pod \
        -- wget -qO - http://localhost:9400/metrics
