# Aether / AssetTrack Air-Gapped Kubernetes Platform

## Overview

This repository contains all infrastructure and platform automation for the air-gapped Aether/AssetTrack Kubernetes environment. It is designed for a fully offline lab, with all images and packages mirrored locally.

**Engineer A scope:** Infra, platform, cluster, registry, monitoring, logging, backup, and GitOps enablement.

---

## Acceptance Criteria

- All nodes use APT mirror at `http://192.168.1.9/mirror`.
- All images are pulled from `https://192.168.1.9` (Harbor); containerd trusts Harbor's cert.
- `kubectl get nodes` shows 3 Ready nodes.
- ArgoCD shows the app synced from `aether-k8s-manifests`.
- Linkerd sidecars are injected and mTLS is active for app namespace.
- Prometheus scrapes `/metrics` from processor-service.
- Loki/Promtail collect logs.
- Velero + MinIO operational; DR plan documented with a runnable command set.

---

## Bastion Image Handling Cheat Sheet

1. **Pull and retag images:**
   ```bash
   # Example for Kubernetes images
   kubeadm config images list --kubernetes-version v1.29.0
   docker pull <UPSTREAM_IMAGE>
   docker tag <UPSTREAM_IMAGE> 192.168.1.9/assettrack/<IMAGE_NAME>:<TAG>
   docker push 192.168.1.9/assettrack/<IMAGE_NAME>:<TAG>
   ```

2. **Preload all required images:**
   - Kubernetes core (kube-apiserver, controller-manager, scheduler, etcd, coredns, pause)
   - CNI (Calico)
   - ArgoCD, Linkerd, Prometheus, Alertmanager, Loki, Promtail, MinIO, Velero, and all app images.

3. **Push to Harbor:**
   ```bash
   docker login https://192.168.1.9 -u admin -p <STRONG_PASSWORD>
   docker push 192.168.1.9/assettrack/<IMAGE>:<TAG>
   ```

---

## End-to-End Happy Path

1. **Run Ansible Playbooks from Bastion:**
   ```bash
   ansible-playbook -i inventories/hosts.ini ansible/playbooks/01_bastion_prep.yml
   ansible-playbook -i inventories/hosts.ini ansible/playbooks/02_configure_nodes.yml
   ansible-playbook -i inventories/hosts.ini ansible/playbooks/03_kubeadm_cluster.yml
   ansible-playbook -i inventories/hosts.ini ansible/playbooks/04_platform_tools.yml
   ```

2. **Verify Cluster:**
   ```bash
   kubectl get nodes -o wide
   kubectl -n argocd get pods
   kubectl -n linkerd get pods
   ```

3. **Ship App:**
   ```bash
   cd app/processor-service
   docker build -t 192.168.1.9/assettrack/processor:<TAG> .
   docker push 192.168.1.9/assettrack/processor:<TAG>
   # Bump image tag in aether-k8s-manifests repo, commit, push
   # ArgoCD will sync automatically
   kubectl -n argocd get applications
   ```

4. **Observability Sanity:**
   ```bash
   kubectl -n monitoring get pods
   kubectl -n logging get pods
   ```

5. **DR Sanity:**
   ```bash
   velero backup create smoke-$(date +%s) --include-namespaces assettrack
   # Simulate PVC delete (see DR-PLAN.md)
   velero restore create --from-backup smoke-<ts>
   ```

---

## Directory Structure

See the root of this repository for all playbooks, roles, manifests, and app code.

---

## Notes

- All secrets and passwords are placeholders; replace as needed.
- All YAML, Dockerfiles, and scripts are valid and ready for use.
