# Ultra-Lightweight Kubernetes Log Pipeline

A highly optimized, production-grade observability pipeline designed specifically for memory-constrained local Kubernetes environments (like Docker Desktop, Minikube, or K3s). 

This project demonstrates how to capture, parse, and visualize structured JSON logs from microservices using less than **150 MB of total RAM**—bypassing the heavy JVM memory requirements of traditional ELK (Elasticsearch, Logstash, Kibana) or OpenSearch stacks.

## The Problem This Solves

Running a full logging stack on a local laptop often leads to `OOMKilled` (Out of Memory) errors. Search engines like OpenSearch and Elasticsearch require a minimum of 1GB to 2GB of RAM just to boot, and their companion visualization tools (Kibana/Dashboards) consume another 300MB-500MB.

This project replaces the traditional Java-based stack with modern, compiled languages (Rust and Go) to achieve the exact same architectural pattern at a fraction of the cost.

## Memory Footprint Comparison

| Component | Traditional Stack (ELK / OpenSearch) | This Stack (Vector + ZincSearch) | Memory Reduction |
| :--- | :--- | :--- | :--- |
| **Search Engine** | OpenSearch / ES: `~1024 MiB+` | ZincSearch: `~50-100 MiB` | **~90% less** |
| **Dashboard UI** | Dashboards / Kibana: `~300-400 MiB` | Integrated inside ZincSearch | **100% saved** |
| **Log Shipper** | Logstash / Fluentd: `~200-500 MiB` | Vector: `~30-50 MiB` | **~75% less** |
| **Total Footprint** | **~1.8 GB - 2.2 GB RAM** | **< 150 MB RAM** | **~93% overall** |

## Architecture & Data Flow

## Helm Installation:
> curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
> chmod 700 get_helm.sh
> ./get_helm.sh

```text
[ order-service ]  --HTTP-->  [ payment-service ]
        │                             │
   (JSON stdout)                 (JSON stdout)
        ▼                             ▼
   /var/log/pods/                /var/log/pods/
        │                             │
        └──────────────┬──────────────┘
                       ▼
            [ Vector (DaemonSet) ]
                       │
             Vector Remap Language (VRL)
                       ▼
      [ ZincSearch (Go-based Lucene Engine) ]
                       │
          Web UI (NodePort :30080)


1. The Microservices (ecommerce namespace)
Two lightweight Alpine Linux containers simulate an e-commerce backend.

Payment Service: Uses netcat to listen for incoming HTTP connections and responds with a 200 OK. It logs the transaction as a JSON payload.

Order Service: Uses curl to continuously ping the payment service, logging the HTTP status codes it receives in JSON format.

2. The Log Router: Vector (vector namespace)
Vector is a high-performance observability router written in Rust. Deployed as a DaemonSet, it automatically tails the hidden /var/log/pods/ directory on the Kubernetes node.

The Parsing Problem: Kubernetes wraps all container output inside a raw text field called .message.

The VRL Solution: We use Vector Remap Language (VRL) to unpack this wrapper on the fly. Vector detects the JSON, extracts fields like service, status, and action, promotes them to the root level of the event, and deletes the duplicate raw string to save database storage.

3. The Search Engine: ZincSearch (logging namespace)
ZincSearch is a lightweight alternative to Elasticsearch written in Go.

It exposes an Elasticsearch-compatible bulk ingestion API (at the /es/ sub-path), meaning Vector can send logs to it natively without any custom plugins.

It features a built-in Vue.js web interface, completely eliminating the need to host a separate Kibana or Dashboards container.


Engineering Details
VRL Ingestion & Parsing
Kubernetes wraps all standard container outputs into a nested JSON wrapper string under .message. The pipeline applies Vector Remap Language to lift application parameters into root queryable fields:

Code snippet
parsed, err = parse_json(.message)
if err == null {
  . = merge!(., parsed) # Fallible assignment handled via bang (!)
  del(.message)         # Eliminate data duplication
}
Path Disambiguation for ZincSearch ES API
ZincSearch serves native indexing on /api and hosts its Elasticsearch-compatible bulk endpoints under /es/. Vector's sink explicitly addresses http://zincsearch.logging.svc.cluster.local:4080/es/ to avoid 404 handler drops.
