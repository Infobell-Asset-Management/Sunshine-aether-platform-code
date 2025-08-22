# Repository Structure

## aether-platform-code

```
.
├── ansible/
├── app/
├── kubeadm/
├── platform/
└── README.md
```

## aether-k8s-manifests

```
.
├── namespaces.yaml
├── networkpolicies/
├── security/
├── processor/
├── monitoring/
├── logging/
└── README.md
```

## GitOps Flow

1. Build app image on Bastion.
2. Push image to Harbor (`192.168.1.9/assettrack/processor:<TAG>`).
3. Bump image tag in `aether-k8s-manifests/processor/deployment.yaml`.
4. Commit and push to `aether-k8s-manifests`.
5. ArgoCD detects change and syncs rollout.
