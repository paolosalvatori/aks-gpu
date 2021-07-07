#!/bin/bash

helm upgrade kube-prometheus-stack \
    prometheus-community/kube-prometheus-stack \
    --namespace kube-prometheus-stack  \
    --values prometheus.stack.values.yaml