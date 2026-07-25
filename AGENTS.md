# AGENTS.md — lab-eks-auto

## Terraform

Root working dir: `terraform/environments/dev/`

```
cd terraform/environments/dev
terraform fmt -recursive ../../    # format all modules
terraform validate                 # after fmt
tflint                             # after validate
```

- Always run above 3 commands in order after any Terraform change.
- **No remote state backend** configured — uses local state.
- Modules are in `terraform/modules/{vpc,eks,ecr,acm}/`.
- Resource labels use `main` (e.g. `aws_vpc.main`), never `this`.
- Version constraints in `providers.tf` — no separate `versions.tf`.
- Helm & kubernetes providers in `providers.tf` authenticate via `aws eks get-token`.
- K8s secrets use default envelope encryption (AWS-owned key) — `encryption_config` is omitted.
- VPC module: private subnets only by default; setting `public_subnet_cidrs` adds IGW + NAT Gateway + public subnets with `kubernetes.io/role/elb` tag. Only S3 Gateway VPC Endpoint created (interface endpoints commented out).
- ACM module: requests cert from `var.domain_names` via DNS validation; auto-creates Route53 CNAME records if `route53_zone_name` is set, else outputs manual validation options.
- ALB uses EKS Auto Mode's built-in controller (no separate AWS LB Controller install) — configured in `modules/eks/ingressclasses.tf` with `scheme=internet-facing`, `group.name=main`, set as default class.
- EKS Auto Mode uses `AmazonEKSBlockStoragePolicyV2` (not the non-V2 access policy).
- EKS cluster is **public+private** (`endpoint_public_access = true` with restricted CIDRs from `var.public_access_cidrs`).
- EKS auth: API authentication mode with `bootstrap_cluster_creator_admin_permissions = true`. Root account gets `AmazonEKSAdminPolicy` + `AmazonEKSClusterAdminPolicy`.
- EKS Auto Mode config: `bootstrap_self_managed_addons = false`, `compute_config` (empty node_pools list), `storage_config`, `kubernetes_network_config` all enabled.
- ArgoCD is bootstrapped via Terraform (`modules/eks/argo-cd.tf` uses `helm_release`). The ArgoCD Application manifests in `kubernetes/` then manage ArgoCD, myapp, and Prometheus declaratively via GitOps.
- ECR repository `main`: defaults `force_delete=true`, `scan_on_push=true`, `image_tag_mutability=MUTABLE`. Lifecycle policy expires untagged images after 14 days.
- Node pool uses Karpenter (`karpenter.sh/v1` NodePool) with NodeClass selecting subnets tagged `kubernetes.io/role/internal-elb=1` and SGs tagged `kubernetes.io/cluster/{name}=owned`.
- gp3 StorageClass set as default with `WaitForFirstConsumer`, `Delete` reclaim, `encrypted=true`.
- `eksadmin` IAM role + IAM group for admin access — group members can `sts:AssumeRole` into the role.

## EKS Cluster

- To update kubeconfig:
  ```
  ./eks-connect.sh lab-eks-auto
  ```
  Default region: `us-east-2` (overridable via `REGION` env var).

## App (`app/`)

- ES module (`"type": "module"`) — use `import` not `require()`.
- Dockerfile uses `npm ci` — **do not** delete `package-lock.json`.
- `build.sh` auto-detects account ID, logs in to ECR, builds & pushes image; outputs image URI formatted for `terraform.tfvars`:
  ```
  ../app/build.sh myapp
  ```
- Endpoints: `/healthz` (liveness), `/readyz` (readiness), `/info` (JSON), `/` (HTML).

## Kubernetes (`kubernetes/`)

- ArgoCD Application manifests deploy ArgoCD itself, myapp (from external repo `vazthunder/lab-eks-auto`), and Prometheus stack.
- ArgoCD sync uses `ServerSideApply=true` for argo-cd and prometheus apps.
- The GitHub PAT secret for the myapp repo is **not** in the manifest — see the commented-out `kubectl create secret generic` command at the top of `argocd-myapp.yaml`.

## Project layout

```
app/               Node.js Express test app (ESM, distroless container)
eks-connect.sh     kubeconfig updater (`aws eks update-kubeconfig`)
kubernetes/        ArgoCD Application manifests (argocd, myapp, prometheus)
terraform/
├── modules/       vpc, eks, ecr, acm
│   └── eks/       includes argo-cd.tf (bootstraps ArgoCD via Helm)
└── environments/  dev/ (working dir)
```

## Other

- No CI/CD pipeline, no tests, no pre-commit hooks configured.
- See `INSTRUCTIONS.md` for session response conventions (prefix, style, lint requirements).
