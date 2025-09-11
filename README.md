# DevOps Portfolio Lab: Production-Ready Microservice Platform (Local Kubernetes)

This project showcases end-to-end DevOps skills using only free, open-source tools:
- Docker for containerization
- Linux for automation and host management
- Kubernetes (kind) for orchestration, Helm for packaging
- Ansible for bootstrapping the environment and cluster
- Terraform for infra (AWS-like services via LocalStack)
- GitHub Actions + GHCR for CI/CD
- Optional: Prometheus/Grafana for observability, Trivy for image scanning

## Architecture (local-only, no paid cloud)
```mermaid
flowchart LR
  Dev[Dev Machine (Linux)] -->|Ansible| Kind[(Kubernetes Cluster)]
  Dev -->|Terraform| LocalStack[(AWS via LocalStack)]

  subgraph Kind Cluster
    Ingress[NGINX Ingress]
    UsersAPI[users-api Deployment]
    Postgres[(PostgreSQL PVC)]
    Config[ConfigMaps/Secrets]
    HPA[Horizontal Pod Autoscaler]
  end

  UsersAPI --> Postgres
  UsersAPI -->|S3/Dynamo APIs| LocalStack

  CI[GitHub Actions] --> GHCR[(GHCR Images)]
  CI -->|Build/Scan/Push| GHCR
  Dev -->|Helm Deploy / or ArgoCD| Kind
```

## What you'll demonstrate
- Reproducible infra and app with `make` and Ansible
- Container best practices (multi-stage, non-root, scanning)
- Kubernetes production basics (Ingress, HPA, probes, policies)
- IaC with Terraform targeting LocalStack (S3/Dynamo)
- CI/CD with GitHub Actions and GHCR
- Clear docs and diagrams for interview walkthrough

## Quickstart
Requirements:
- Ubuntu 22.04+ (or WSL2), Docker installed and running
- Git, Make
- A GitHub account (public repo) for CI and GHCR

1) Clone this repo, then:
```bash
make bootstrap
```
What it does:
- Ansible installs: kind, kubectl, helm, terraform, LocalStack CLI dependencies
- Creates a kind cluster
- Installs NGINX Ingress and Metrics Server
- Starts LocalStack (via docker-compose)
- Applies Terraform to provision S3 bucket and DynamoDB table (in LocalStack)

2) Build, scan, push image:
```bash
make build push
```

3) Deploy to Kubernetes:
```bash
make deploy
```

4) Access the app:
- Add `/etc/hosts` entry: `127.0.0.1 users.local`
- Open http://users.local/

5) Tear down:
```bash
make destroy
```

## CI/CD
- GitHub Actions runs on PRs and main merges:
  - Build multi-stage Docker image
  - Trivy scan
  - Push to GHCR with commit SHA tags
- Optional: adopt GitOps with ArgoCD later (stretch goal)

## Stretch goals
- GitOps: Install ArgoCD via Ansible; deploy Helm charts from this repo
- Observability: kube-prometheus-stack + Loki + Grafana dashboards
- Policy: Kyverno or Gatekeeper (deny privileged, enforce runAsNonRoot)
- SBOM/Signing: Syft, Grype, Cosign
- Secrets: External Secrets Operator with local SOPS + age

## Repo layout
```
.
├── .github/workflows/ci.yml
├── Makefile
├── ansible/
│   ├── inventory
│   ├── site.yml
│   └── roles/
│       └── common/tasks/main.yml
├── docker/
│   └── users-api/Dockerfile
├── helm/
│   └── users-api/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
├── terraform/
│   └── main.tf
├── docker-compose.localstack.yml
├── LICENSE
└── .gitignore
```

## Demo script (for interviews)
- Show architecture diagram (Mermaid in README)
- Run `make bootstrap` (explain Ansible, kind, Ingress, LocalStack)
- Open `helm/users-api/values.yaml` (resources, probes, securityContext)
- Run `make build push deploy` (explain CI steps)
- `kubectl get pods,svc,ingress` and show HPA scaling with `kubectl top`
- Show Terraform outputs and local S3 bucket in LocalStack
- Mention stretch goals implemented or planned

## Notes
- The app container image and Helm values are generic; plug in your own users-api (e.g., Spring Boot).
- Everything runs locally, using free tools.

---

Owner-specific defaults:
- GHCR repo used in values: `ghcr.io/faizan00parvez/users-api`

Add your application code under a separate repo or in this one (Java Spring Boot example expected by Dockerfile). Update paths as needed.
