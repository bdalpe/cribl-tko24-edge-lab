#!/bin/bash

open -a Docker

# Start the Kind Cluster
kind create cluster --config kind/cluster.yaml

# Pre-load the Cribl Docker image to the Kind Nodes
docker pull cribl/cribl:latest
kind load docker-image cribl/cribl:latest --nodes kind-control-plane,kind-worker,kind-worker2

# Add Helm Repository for Cribl Charts
helm repo add cribl https://criblio.github.io/helm-charts/
helm repo update cribl

# Install Cribl Leader Chart Helm Chart
helm install -n cribl --create-namespace -f helm/leader.yaml leader cribl/logstream-leader
kubectl rollout -n cribl status deployment/leader

# Install Cribl Stream Worker Group Helm Chart
helm install -n cribl -f helm/worker-group.yaml default cribl/logstream-workergroup
kubectl rollout -n cribl status deployment/default-logstream-workergroup

# Install Cribl Edge Helm Chart
helm install -n cribl -f helm/edge.yaml edge cribl/edge
kubectl rollout -n cribl status daemonset/edge

# Setup noise generator
kubectl apply -f k8s/noise.yaml
