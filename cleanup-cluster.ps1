#!/usr/bin/env pwsh

Write-Host "=== Kubernetes Cluster Cleanup Script ===" -ForegroundColor Cyan
Write-Host ""

# 1. Delete all Evicted pods
Write-Host "1. Cleaning up Evicted pods..." -ForegroundColor Yellow
kubectl get pods -A --field-selector=status.phase=Failed -o json | ConvertFrom-Json | ForEach-Object {
    $_.items | Where-Object { $_.status.reason -eq "Evicted" } | ForEach-Object {
        $ns = $_.metadata.namespace
        $name = $_.metadata.name
        Write-Host "  Deleting $ns/$name"
        kubectl delete pod $name -n $ns --force --grace-period=0 2>$null
    }
}

# 2. Delete all Failed pods
Write-Host "2. Cleaning up Failed pods..." -ForegroundColor Yellow
kubectl get pods -A --field-selector=status.phase=Failed -o json | ConvertFrom-Json | ForEach-Object {
    $_.items | ForEach-Object {
        $ns = $_.metadata.namespace
        $name = $_.metadata.name
        Write-Host "  Deleting $ns/$name"
        kubectl delete pod $name -n $ns --force --grace-period=0 2>$null
    }
}

# 3. Delete all Completed pods
Write-Host "3. Cleaning up Completed pods..." -ForegroundColor Yellow
kubectl get pods -A --field-selector=status.phase=Succeeded -o json | ConvertFrom-Json | ForEach-Object {
    $_.items | ForEach-Object {
        $ns = $_.metadata.namespace
        $name = $_.metadata.name
        Write-Host "  Deleting $ns/$name"
        kubectl delete pod $name -n $ns 2>$null
    }
}

# 4. Delete ContainerStatusUnknown pods
Write-Host "4. Cleaning up ContainerStatusUnknown pods..." -ForegroundColor Yellow
kubectl get pods -A -o wide | Select-String "ContainerStatusUnknown|Unknown" | ForEach-Object {
    $fields = $_ -split '\s+'
    $ns = $fields[0]
    $name = $fields[1]
    Write-Host "  Deleting $ns/$name"
    kubectl delete pod $name -n $ns --force --grace-period=0 2>$null
}

# 5. Delete stuck Grafana pods
Write-Host "5. Cleaning up stuck Grafana pods..." -ForegroundColor Yellow
@('kube-stack-grafana-7f7d4dc667-26hz2', 'kube-stack-grafana-7f7d4dc667-78k5r', 'kube-stack-grafana-7f7d4dc667-7mvrl') | ForEach-Object {
    Write-Host "  Deleting monitoring/$_"
    kubectl delete pod $_ -n monitoring --force --grace-period=0 2>$null
}

# 6. Uncordon all nodes
Write-Host "6. Uncordoning all nodes..." -ForegroundColor Yellow
@('node1.ysftek.lab', 'node2.ysftek.lab', 'node3.ysftek.lab') | ForEach-Object {
    kubectl uncordon $_ 2>$null
}

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Summary of pods by status:" -ForegroundColor Cyan
kubectl get pods -A --no-headers | ForEach-Object { ($_ -split '\s+')[3] } | Group-Object | Sort-Object Count -Descending | Format-Table Count, Name -AutoSize

Write-Host "Node status:" -ForegroundColor Cyan
kubectl get nodes

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. SSH to each node and run: crictl rmi --prune"
Write-Host "2. SSH to each node and run: journalctl --vacuum-time=3d"
Write-Host "3. Check disk usage on nodes: df -h"
