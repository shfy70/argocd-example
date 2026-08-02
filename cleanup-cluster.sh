#!/bin/bash

echo "=== Kubernetes Cluster Cleanup Script ==="
echo ""

# 1. Delete all Evicted pods
echo "1. Cleaning up Evicted pods..."
kubectl get pods -A --field-selector=status.phase=Failed --no-headers | \
  grep Evicted | \
  awk '{print "-n " $1 " " $2}' | \
  xargs -r -L1 kubectl delete pod --force --grace-period=0

# 2. Delete all Failed pods
echo "2. Cleaning up Failed pods..."
kubectl get pods -A --field-selector=status.phase=Failed --no-headers | \
  awk '{print "-n " $1 " " $2}' | \
  xargs -r -L1 kubectl delete pod --force --grace-period=0

# 3. Delete all Completed pods
echo "3. Cleaning up Completed pods..."
kubectl get pods -A --field-selector=status.phase=Succeeded --no-headers | \
  awk '{print "-n " $1 " " $2}' | \
  xargs -r -L1 kubectl delete pod

# 4. Delete ContainerStatusUnknown pods
echo "4. Cleaning up ContainerStatusUnknown pods..."
kubectl get pods -A --no-headers | \
  grep "ContainerStatusUnknown\|Unknown" | \
  awk '{print "-n " $1 " " $2}' | \
  xargs -r -L1 kubectl delete pod --force --grace-period=0

# 5. Delete stuck Grafana pods (if they exist)
echo "5. Cleaning up stuck Grafana pods..."
kubectl delete pod kube-stack-grafana-7f7d4dc667-26hz2 -n monitoring --force --grace-period=0 2>/dev/null || true
kubectl delete pod kube-stack-grafana-7f7d4dc667-78k5r -n monitoring --force --grace-period=0 2>/dev/null || true
kubectl delete pod kube-stack-grafana-7f7d4dc667-7mvrl -n monitoring --force --grace-period=0 2>/dev/null || true

# 6. Uncordon all nodes
echo "6. Uncordoning all nodes..."
kubectl uncordon node1.ysftek.lab 2>/dev/null || true
kubectl uncordon node2.ysftek.lab 2>/dev/null || true
kubectl uncordon node3.ysftek.lab 2>/dev/null || true

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "Summary of pods by status:"
kubectl get pods -A --no-headers | awk '{print $4}' | sort | uniq -c
echo ""
echo "Node status:"
kubectl get nodes
echo ""
echo "NEXT STEPS:"
echo "1. SSH to each node and run: crictl rmi --prune"
echo "2. SSH to each node and run: journalctl --vacuum-time=3d"
echo "3. Check disk usage: kubectl get pods -A | grep -E 'Evicted|Error|Unknown'"
