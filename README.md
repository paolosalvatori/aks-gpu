## Use GPUs for compute-intensive workloads on Azure Kubernetes Service (AKS)

Graphical processing units (GPUs) are often used for compute-intensive
workloads such as graphics and visualization workloads.  AKS supports
the creation of GPU-enabled node pools to run these compute-intensive
workloads in Kubernetes. For more information on AKS , see [Use GPUs for
compute-intensive workloads on Azure Kubernetes Service
(AKS)](https://docs.microsoft.com/en-us/azure/aks/gpu-cluster). For more
information on available GPU-enabled virtual machines, see [GPU
optimized VM sizes in
Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-gpu).

Azure supports creating a brand [new AKS cluster with a GPU-enabled
default node
pool](https://docs.microsoft.com/en-us/azure/aks/gpu-cluster#create-an-aks-cluster),
as well as adding one more GPU-enabled node pools to an existing cluster
using for example the [az aks nodepool
add](https://docs.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az_aks_nodepool_add)
command. Before the GPUs in the nodes can be used, you must deploy a
[DaemonSet for the NVIDIA device
plugin](https://docs.microsoft.com/en-us/azure/aks/gpu-cluster#install-nvidia-device-plugin).
This DaemonSet runs a pod on each node to provide the required drivers
for the GPUs. As alternative to these steps, AKS provides a [specialized
GPU
image](https://docs.microsoft.com/en-us/azure/aks/gpu-cluster#use-the-aks-specialized-gpu-image-preview)
that already contains the [NVIDIA device plugin for
Kubernetes](https://github.com/NVIDIA/k8s-device-plugin).

## AKS Cluster Autoscaling

To keep up with application demands in Azure Kubernetes Service (AKS),
you may need to adjust the number of GPU nodes that run your
compute-intensive workloads. The [AKS cluster
autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler)
component can watch for pods in your cluster that can't be scheduled
because of resource constraints. When issues are detected, the number of
nodes in a node pool is increased to meet the application demand. Nodes
are also regularly checked for a lack of running pods, with the number
of nodes then decreased as needed. This ability to automatically scale
up or down the number of nodes in your AKS cluster lets you run an
efficient, cost-effective cluster.

To adjust to changing application demands, such as between the workday
and evening or on a weekend, or when running on-demand,
compute-intensive jobs, clusters often need a way to automatically scale
out the number of nodes to schedule the increased number of pods. AKS
clusters can scale in one of two ways:

-   The cluster autoscaler watches for pods that can't be scheduled on
    nodes because of resource constraints. The cluster then
    automatically increases the number of nodes.

-   The [horizontal pod
    autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) uses
    the Metrics Server in a Kubernetes cluster to monitor the resource
    demand of pods. If an application needs more resources, the number
    of pods is automatically increased to meet the demand.

<p align="center">
    <img src="media\image1.png" style="width:4.42569in;height:2.33333in" alt="The cluster autoscaler and horizontal pod autoscaler often work together to support the required application demands" />
</p>

Both the horizontal pod autoscaler and cluster autoscaler can also
decrease the number of pods and nodes as needed. The cluster autoscaler
decreases the number of nodes when there has been unused capacity for a
period of time. Pods on a node to be removed by the cluster autoscaler
are safely scheduled elsewhere in the cluster. For more information, see
[Automatically scale a cluster to meet application demands on Azure
Kubernetes Service
(AKS)](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler).
Note: when the AKS cluster is composed of multiple node pools, the
autoscaler needs to be activated separately for each node pool.

## Accelerated Networking

For AKS nodes, we recommend a minimum size of Standard\_NC6*.* I
strongly recommend to use a GPU-enabled VM SKU that supports
[accelerated
networking](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli).

Accelerated networking greatly improves networking performance when
accessing PaaS services such as Azure SQL Database, Azure Cosmos DB, or
Storage Accounts by increasing throughput,

reducing latency, jitter, and CPU utilization. Accelerated networking is
particularly indicated for demanding network workloads on supported VM
types.

## Data Center GPU Manager

Monitoring stacks usually consist of a metrics collector, a time-series
database to store metrics, and a visualization layer. A popular
open-source stack
is [Prometheus](https://laptrinhx.com/link/?l=https%3A%2F%2Fprometheus.io%2F),
used along
with [Grafana](https://laptrinhx.com/link/?l=https%3A%2F%2Fgrafana.com%2F) as
the visualization tool to create rich dashboards. Prometheus also
includes [Alertmanager](https://github.com/prometheus/alertmanager) to
create and manage alerts. Prometheus is deployed along
with [kube-state-metrics](https://laptrinhx.com/link/?l=https%3A%2F%2Fgithub.com%2Fkubernetes%2Fkube-state-metrics) and [node\_exporter](https://laptrinhx.com/link/?l=https%3A%2F%2Fgithub.com%2Fprometheus%2Fnode_exporter) to
expose cluster-level metrics for Kubernetes API objects and node-level
metrics such as CPU utilization. The figure below shows a sample
architecture with Prometheus and Grafana.

<p align="center">
    <img src="media\image2.png" style="width:5.90764in;height:3.53542in" alt="Image showing the various components of a Prometheus + Grafana architecture for gathering telemetry, including the server, Alertmanager, and UI components." />
</p>

Kubernetes includes experimental support for managing [AMD and NVIDIA
GPUs](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/)
across several nodes.
[DCGM-Exporter](https://github.com/NVIDIA/gpu-monitoring-tools) is a
tool based on the Go APIs to [NVIDIA
DCGM](https://developer.nvidia.com/dcgm) that allows users to gather GPU
metrics and understand workload behavior or monitor GPUs in
clusters. DCGM-Exporter is written in Go and exposes GPU metrics at an
HTTP endpoint (/metrics) for monitoring solutions such as
[Prometheus](https://prometheus.io/docs/introduction/overview/).
DCGM-Exporter is also configurable. You can customize the GPU metrics to
be collected by DCGM by using an input configuration file in the .csv
format. For more information on available metrics, see
[here](https://docs.nvidia.com/datacenter/dcgm/1.7/dcgm-api/group__dcgmFieldIdentifiers.html#group__dcgmFieldIdentifiers_1gb87e5a4c725b0901f3c9972fb4ee87f6)
and
[here](https://github.com/NVIDIA/gpu-monitoring-tools/blob/master/etc/dcgm-exporter/dcp-metrics-included.csv).

DCGM-Exporter collects metrics for all available GPUs on a node.
However, in Kubernetes, you might not necessarily know which GPUs in a
node would be assigned to a pod when it requests GPU resources. Starting
in v1.13, kubelet has added a device monitoring feature that lets you
find out the assigned devices to the
pod[—](https://laptrinhx.com/monitoring-gpus-in-kubernetes-with-dcgm-2081352294/)pod
name, pod namespace, and device ID—using a pod-resources socket. The
http server in DCGM-Exporter connects to the kubelet pod-resources
server (/var/lib/kubelet/pod-resources) to identify the GPU devices
running on a pod and appends the GPU devices pod information to the
metrics collected.

<img src="media\image3.png" style="width:5.57431in;height:3.56597in" alt="Image showing the architecture of dcgm-exporter for gathering telemetry with Prometheus with the node-exporter, dcgm-exporter components, and service monitor components." />

For more information on the NVIDIA Data Center GOU Manager, see [NVIDIA
Data Center GPU Manager](https://github.com/NVIDIA/DCGM) GitHub repo.
For more information on the DCGM-Exporter, see [NVIDIA GPU Monitoring
Tools](https://github.com/NVIDIA/gpu-monitoring-tools) GitHub repo. For
information on the profiling metrics available from DCGM, refer to [this
section](https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-user-guide/feature-overview.html#profiling) in
the documentation. As an alternative to the DCGM-Exporter, you can use
the [NVIDIA GPU Operator](https://github.com/NVIDIA/gpu-operator).

## DCGM Installation

In order to install DCGM and Prometheus + Grafana, follows the
instructions at [Integrating GPU Telemetry into
Kubernetes](https://docs.nvidia.com/datacenter/cloud-native/kubernetes/dcgme2e.html).
During the installation, I stumbled into the issues described in this
[post](https://stackoverflow.com/questions/65076998/how-to-scale-azures-kubernetes-service-aks-based-on-gpu-metrics)
on Stackoverflow.

-   [DCGM-Exporter is not configured to track the
    DCGM\_FI\_DEV\_GPU\_UTIL metric by
    default](https://github.com/NVIDIA/gpu-monitoring-tools/issues/143).
    This metric captures the GPU utilization. I solved the problem by
    creating a **Dockerfile** to build a custom Docker image based on
    the latest base image of the DCGM-Exporter. The Dockerfile uncomments
    the  DCGM\_FI\_DEV\_GPU\_UTIL in the configuration csv that contains
    the metrics collected by the DaemonSet on GPU nodes. You can build
    the Docker image using the **build-docker-image.sh** script and push
    it to your Azure Container Registry (ACR) using the
    **push-docker-image.sh** script. Another approach is to create a new csv file
		containing the metrics the DCGM-Exporter should collect and export from GPU-enabled nodes.

```bash
#!/bin/bash

#!/bin/bash

# Variables
acrName="YOUR-ACR-NAME"
imageName="dcgm-exporter"
tag="latest"

# Login to ACR
az acr login --name ${acrName,,} 

# Retrieve ACR login server. Each container image needs to be tagged with the loginServer name of the registry. 
echo "Logging to [$acrName] Azure Container Registry..."
loginServer=$(az acr show --name $acrName --query loginServer --output tsv)

# Tag the local image with the loginServer of ACR
docker tag $imageName:$tag $loginServer/$imageName:$tag

# Push local container image to ACR
docker push $loginServer/$imageName:$tag

# Show the repository
echo "This is the [$imageName:$tag] container image in the [$acrName] Azure Container Registry:"
az acr repository show --name $acrName \
                       --image $imageName:$tag 
```

-   [DCGM-Exporter pod is recycling due a too short readiness
    probe.](https://github.com/NVIDIA/gpu-monitoring-tools/issues/161)
    Since the
    [InitialDelaySeconds](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
    of the livenessProbe and readinessProbe is not parametrized in the
    original Helm chart of the DCGM-Exporter, you cannot override the
    value that is hardcoded in the template to increase the time
    interval when deploying the chart. Hence, I downloaded and
    customized the chart that you can find in the zip file under the
    **dcgm-exporter** folder. The chart is also parametrized to use the
    custom image above. The docker image has been registered in an Azure
    Container Registry used by the AKS cluster. You can deploy the Helm
    chart by using the **install-local-chart.sh** script or use the
    **install-dcgm-exporter.sh** to install the original Helm chart.

```bash
#!/bin/bash

# For more information, see https://docs.nvidia.com/datacenter/cloud-native/kubernetes/dcgme2e.html 
# Also look at https://github.com/NVIDIA/gpu-monitoring-tools/blob/master/etc/dcgm-exporter/default-counters.csv for metrics
namespace="dcgm-exporter"
chartName="./dcgm-exporter"
releaseName="dcgm-exporter"

# check if namespace exists in the cluster
result=$(kubectl get ns -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "$namespace namespace already exists in the cluster"
else
    echo "$namespace namespace does not exist in the cluster"
    echo "creating $namespace namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Install Helm chart
result=$(helm list -n $namespace | grep $releaseName | awk '{print $1}')

if [[ -n $result ]]; then
    echo "[$releaseName] already exists in the [$namespace] namespace"
else
    # Install the Helm chart
    echo "Deploying [$releaseName] to the [$namespace] namespace..."
    helm install $releaseName $chartName \
        --namespace $namespace \
        --values values.yaml
fi

# List pods
kubectl get pods -n $namespace -o wide
```

The **add-gpu-node-pool.sh** Bash script in the zip file can be used to
add a GPU-enabled node pool to an existing AKS cluster. The script:

```bash
#!/bin/bash

# Variables
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
```

-   Sets enables the autoscaler on the new node pool, and sets a minimum
    number of nodes to 1 and a maximum to 3.

-   Uses the new [specialized GPU
    image](https://docs.microsoft.com/en-us/azure/aks/gpu-cluster#use-the-aks-specialized-gpu-image-preview)
    that already contains the [NVIDIA device plugin for
    Kubernetes](https://github.com/NVIDIA/k8s-device-plugin).

-   Add a taint to GOU-enabled nodes: sku=gpu:NoSchedule. Hence, in
    order to run pods and jobs on this node pool, their definition needs
    to contain the following toleration:

```yaml
tolerations:
	- key: "sku"
		operator: "Equal"
		value: "gpu"
		effect: "NoSchedule"
```

In case you deploy the GPU-enabled node pool using the standard VM
image, the zip file also contains the **create-plugin-ds.sh** script to
deploy NVIDIA plugin defined in the **nvidia-device-plugin-ds.yaml**
manifest.

As described at [Integrating GPU Telemetry into
Kubernetes](https://docs.nvidia.com/datacenter/cloud-native/kubernetes/dcgme2e.html),
you can install Prometheus and Grafana using the
[kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stackofficial)
Helm chart. If you already installed this Helm chart in your AKS
cluster, you can use the **upgrade-prometheus-stack.sh** script and
**prometheus.stack.values.yaml** values file in the zip file to make the
necessary changes in the current setup and in particular to configure
Prometheus to scrape GPU metrics. Note: make sure to specify the
namespace that hosts the DCGM-Exporter DaemonSet, in my case
dcgm-exporter.

```yaml
# AdditionalScrapeConfigs allows specifying additional Prometheus scrape configurations. Scrape configurations
# are appended to the configurations generated by the Prometheus Operator. Job configurations must have the form
# as specified in the official Prometheus documentation:
# https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config. As scrape configs are
# appended, the user is responsible to make sure it is valid. Note that using this feature may expose the possibility
# to break upgrades of Prometheus. It is advised to review Prometheus release notes to ensure that no incompatible
# scrape configs are going to break Prometheus after the upgrade.
#
# The scrape configuration example below will find master nodes, provided they have the name .*mst.*, relabel the
# port to 2379 and allow etcd scraping provided it is running on all Kubernetes master nodes
#
additionalScrapeConfigs:
- job_name: gpu-metrics
  scrape_interval: 1s
  metrics_path: /metrics
  scheme: http
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - dcgm-exporter
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: kubernetes_node
```

Finally, you need to install the [Prometheus Adapter for Kubernetes
Metrics APIs](https://github.com/kubernetes-sigs/prometheus-adapter)
which provides an  implementation of the Kubernetes [resource
metrics](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/resource-metrics-api.md), [custom
metrics](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/custom-metrics-api.md),
and [external
metrics](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/external-metrics-api.md) APIs.
This adapter is therefore suitable for use with the autoscaling/v2
Horizontal Pod Autoscaler in Kubernetes 1.6+. You can use the
install-**prometheus-adapter.sh** script to install the Prometheus
Adapter for Kubernetes Metrics APIs.

```bash
#!/bin/bash

# For more information, see https://github.com/kubernetes-sigs/prometheus-adapter 
namespace="prometheus-adapter"
repoName="prometheus-community"
repoUrl=https://prometheus-community.github.io/helm-charts
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
```

In Kubernetes, to scale an application and provide a reliable service,
you need to understand how the application behaves when it is deployed.
You can examine application performance in a Kubernetes cluster by
examining the
containers, [pods](https://kubernetes.io/docs/concepts/workloads/pods/), [services](https://kubernetes.io/docs/concepts/services-networking/service/),
and the characteristics of the overall cluster. Kubernetes provides
detailed information about an application's resource usage at each of
these levels. This information allows you to evaluate your application's
performance and where bottlenecks can be removed to improve overall
performance. In Kubernetes, application monitoring does not depend on a
single monitoring solution. On new clusters, you can use [resource
metrics](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/#resource-metrics-pipeline) or [full
metrics](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/#full-metrics-pipeline) pipelines
to collect monitoring statistics. You can use the following command to
access the [CPU and memory
metrics](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
via the **metrics.k8s.io** API natively supported by Kubernetes.

```bash
# Get pods CPU and memory metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods | jq .

# Get nodes CPU and memory metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes | jq .

# Get CPU and memory metrics of the pods running the contoso namespace
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/contoso/pods | jq .
```

Custom metrics can accessed invoking the **custom.metrics.k8s.io** API:

```bash
# Get custom metrics
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq -r . 

# Get DCGM_FI_DEV_GPU_UTIL metrics
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1  | jq -r '.resources[] | select(.name | contains("DCGM_FI_DEV_GPU_UTIL"))'
```

To review the metrics collected by the DCGM-Exporter, you can use
**get-dcgm-exporter-metrics.sh** script which connects to one of the
pods of the DaemonSet and retrieves the metrics from the HTTP server
(<http://localhost:9400/metrics>) of DCGM-Exporter.

Finally, make sure to install the [DCGM dashboard in
Grafana](https://docs.nvidia.com/datacenter/cloud-native/kubernetes/dcgme2e.html#dcgm-dashboard-in-grafana).

## Test

You can proceed as follows to check that the GPU-enabled node pool
autoscaling works as expected. You can run the **run-jobs.sh** script
specifying the number of jobs that you want to run. The job is defined
in the **samples-tf-mnist-demo.yaml** manifest and uses a toleration to
run on a worker node in the GPU-enabled node pool.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: samples-tf-mnist-demo
  name: samples-tf-mnist-demo
spec:
  template:
    metadata:
      labels:
        app: samples-tf-mnist-demo
    spec:
      containers:
      - name: samples-tf-mnist-demo
        image: mcr.microsoft.com/azuredocs/samples-tf-mnist-demo:gpu
        args: ["--max_steps", "500"]
        imagePullPolicy: IfNotPresent
        resources:
          limits:
           nvidia.com/gpu: 1
      restartPolicy: OnFailure
      tolerations:
      - key: "sku"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"
```

As specified under the resources section, the **samples-tf-mnist-demo**
container requires a nvidia.com/gpu. At the time of this writing, each
container can request one or more GPUs. It is not possible to request a
fraction of a GPU. For more information, see [Schedule
GPUs](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/)
under the Kubernetes documentation.

Before starting the test, take note of the number of GPU nodes. In our
case, the initial number of nodes was 1 and SKU was Standard\_NC6.

<img src="media\image4.png" style="width:6.69306in;height:2.75764in" alt="A picture containing graphical user interface Description automatically generated" />

Run the script with a large number such 20-50. If the current number of
worker nodes and vCores is lower than this number, job pods will remain
in a Pending state. In

<img src="media\image5.png" style="width:6.69306in;height:2.75833in" alt="A picture containing text Description automatically generated" />

If you configured the GPU-enabled node pool for autoscaling, the
autoscaler will increase the number of nodes

<img src="media\image6.png" style="width:6.69306in;height:2.75764in" alt="A picture containing graphical user interface Description automatically generated" />

You can use Prometheus UI to see the GPU utilization
(DCGM\_FI\_DEV\_GPU\_UTIL metric) of individual job containers.

<img src="media\image7.png" style="width:6.69306in;height:3.32917in" alt="Chart, box and whisker chart Description automatically generated" />

The GPU metrics are also visible either in the [NVIDIA DCGME Exporter
Grafana dashboard](https://grafana.com/grafana/dashboards/12239) or the
Prometheus dashboard as can be seen in the following screenshots showing
GPU utilization, memory allocated as the application is running on the
GPU:

<img src="media\image8.png" style="width:6.69306in;height:4.95278in" alt="A picture containing text, indoor Description automatically generated" />

After jobs completed, and GOU nodes are no more used by any workloads,
the number of GPU nodes will scale back to the minimum.

<img src="media\image4.png" style="width:6.69306in;height:2.75764in" alt="A picture containing graphical user interface Description automatically generated" />

## ContainerInsights

Starting with agent version *ciprod03022019*, Container insights
integrated agent now supports monitoring GPU (graphical processing
units) usage on GPU-aware Kubernetes cluster nodes, and monitor
pods/containers requesting and using GPU resources.

Container insights supports monitoring GPU clusters from following GPU
vendors:

-   [NVIDIA](https://developer.nvidia.com/kubernetes-gpu)

-   [AMD](https://github.com/RadeonOpenCompute/k8s-device-plugin)

Container insights automatically starts monitoring GPU usage on nodes,
and GPU requesting pods and workloads by collecting the following
metrics at 60sec intervals and storing them in
the **InsightMetrics** table.

| **Metric name**              | **Metric dimension (tags)**                                                                         | **Description**                                                                                                                                                      |
|------------------------------|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| containerGpuDutyCycle        | container.azm.ms/clusterId, container.azm.ms/clusterName, containerName, gpuId, gpuModel, gpuVendor | Percentage of time over the past sample period (60 seconds) during which GPU was busy/actively processing for a container. Duty cycle is a number between 1 and 100. |
| containerGpuLimits           | container.azm.ms/clusterId, container.azm.ms/clusterName, containerName                             | Each container can specify limits as one or more GPUs. It is not possible to request or limit a fraction of a GPU.                                                   |
| containerGpuRequests         | container.azm.ms/clusterId, container.azm.ms/clusterName, containerName                             | Each container can request one or more GPUs. It is not possible to request or limit a fraction of a GPU.                                                             |
| containerGpumemoryTotalBytes | container.azm.ms/clusterId, container.azm.ms/clusterName, containerName, gpuId, gpuModel, gpuVendor | Amount of GPU Memory in bytes available to use for a specific container.                                                                                             |
| containerGpumemoryUsedBytes  | container.azm.ms/clusterId, container.azm.ms/clusterName, containerName, gpuId, gpuModel, gpuVendor | Amount of GPU Memory in bytes used by a specific container.                                                                                                          |
| nodeGpuAllocatable           | container.azm.ms/clusterId, container.azm.ms/clusterName, gpuVendor                                 | Number of GPUs in a node that can be used by Kubernetes.                                                                                                             |
| nodeGpuCapacity              | container.azm.ms/clusterId, container.azm.ms/clusterName, gpuVendor                                 | Total Number of GPUs in a node.                                                                                                                                      |

For example, the following Kusto Query:

```kusto
let startDatetime = todatetime("2021-07-01 09:30:00.0");
let endDatetime = todatetime("2021-07-01 09:55:00.0");
let interval = 60s;
InsightsMetrics
| where Name == "containerGpuDutyCycle" 
  and TimeGenerated  between(startDatetime .. endDatetime)
| summarize ["Average Container Gpu Duty Cycle"] = avg(Val) by bin(TimeGenerated, interval)
| render timechart
```

Returns the following time chart of the percentage of time over the past
sample period during which GPU was busy/actively processing for a
container. Duty cycle is a number between 1 and 100.

<img src="media\image9.png" style="width:6.69306in;height:2.61875in" alt="Graphical user interface, chart, line chart Description automatically generated" />

              

For more information, see [Configure GPU monitoring with Container
insights](https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-gpu-monitoring).

## KEDA

[Keda](https://keda.sh/) is a [Kubernetes](https://kubernetes.io/)-based
Event Driven Autoscaler. With KEDA, you can drive the scaling of any
container in Kubernetes based on the number of events needing to be
processed. KEDA is a single-purpose and lightweight component that can
be added into any Kubernetes cluster. KEDA works alongside standard
Kubernetes components like the [Horizontal Pod
Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and
can extend functionality without overwriting or duplication. With KEDA
you can explicitly map the apps you want to use event-driven scale, with
other apps continuing to function. This makes KEDA a flexible and safe
option to run alongside any number of any other Kubernetes applications
or frameworks. KEDA also supports [Azure
Monitor](https://keda.sh/docs/2.0/scalers/azure-monitor/) which in turn
supports GPU monitoring on AKS via
[ContainerInsights](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-gpu-monitoring).
Using these two features together, it should be doable to use KEDA to
scale out a GPU-enabled AKS cluster.
