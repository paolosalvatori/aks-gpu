FROM nvcr.io/nvidia/k8s/dcgm-exporter:2.1.8-2.4.0-rc.3-ubuntu18.04

RUN sed -i -e '/^# DCGM_FI_DEV_GPU_UTIL.*/s/^#\ //' /etc/dcgm-exporter/default-counters.csv
RUN sed -i -e '/^# DCGM_FI_DEV_GPU_UTIL.*/s/^#\ //' /etc/dcgm-exporter/dcp-metrics-included.csv

ENTRYPOINT ["/usr/local/dcgm/dcgm-exporter-entrypoint.sh"]