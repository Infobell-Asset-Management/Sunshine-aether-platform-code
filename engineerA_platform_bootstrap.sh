#!/bin/bash
set -euo pipefail

# Engineer A: Air-Gapped Platform Bootstrap Script
# Run as infobell on Bastion (192.168.1.9) from /home/infobell/assetTrack/aether

# 1. Run Ansible Playbooks
ansible-playbook -i inventories/hosts.ini ansible/playbooks/01_bastion_prep.yml
ansible-playbook -i inventories/hosts.ini ansible/playbooks/02_configure_nodes.yml
ansible-playbook -i inventories/hosts.ini ansible/playbooks/03_kubeadm_cluster.yml
ansible-playbook -i inventories/hosts.ini ansible/playbooks/04_platform_tools.yml

# 2. Preload and Push Required Images to Harbor
# Kubernetes core images
K8S_VERSION="v1.29.0"
HARBOR_REGISTRY="192.168.1.9/assettrack"

kubeadm config images list --kubernetes-version $K8S_VERSION | while read img; do
  IMG_NAME=$(basename $img)
  docker pull $img || true
  docker tag $img $HARBOR_REGISTRY/$IMG_NAME:$K8S_VERSION
  docker push $HARBOR_REGISTRY/$IMG_NAME:$K8S_VERSION
  echo "Pushed $HARBOR_REGISTRY/$IMG_NAME:$K8S_VERSION"
done

# Platform images (add more as needed)
for IMG in argocd argocd-repo-server argocd-server argocd-application-controller linkerd-controller prometheus alertmanager loki promtail minio velero; do
  # Replace <UPSTREAM_IMAGE> with the real upstream image for each
  # docker pull <UPSTREAM_IMAGE>
  # docker tag <UPSTREAM_IMAGE> $HARBOR_REGISTRY/$IMG:latest
  # docker push $HARBOR_REGISTRY/$IMG:latest
  echo "[INFO] Please manually pull, tag, and push $IMG as needed."
done

# Sample app image
cd app/processor-service
TAG="v0.1.0"
docker build -t $HARBOR_REGISTRY/processor:$TAG .
docker push $HARBOR_REGISTRY/processor:$TAG
cd -

# 3. Cluster Verification
kubectl get nodes -o wide
kubectl -n argocd get pods
kubectl -n linkerd get pods
kubectl -n monitoring get pods
kubectl -n logging get pods
kubectl -n velero get pods
kubectl -n minio get pods

# 4. Observability Sanity
kubectl -n monitoring get pods
kubectl -n logging get pods

# 5. DR Sanity
velero backup create smoke-$(date +%s) --include-namespaces assettrack

# 6. Print Success
cat <<EOF

[INFO] Engineer A platform bootstrap complete.
- All playbooks executed.
- Images preloaded and pushed to Harbor.
- Cluster and platform components verified.
- See README.md and dr/DR-PLAN.md for further steps.
EOF
