<div align="center">
  
# DevSecOps-Pipeline-CI/CD Security Demonstration


![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Security](https://img.shields.io/badge/Security_First-brightgreen?style=for-the-badge)

**End-to-End Secure Software Delivery Pipeline**

</div>

---

## 🎯 Project Overview

A **fully local DevSecOps CI/CD pipeline** demonstrating automated security scanning at every stage of the software delivery lifecycle. Built to run entirely on Windows 10 + VS Code without cloud dependencies, showcasing enterprise security practices in a reproducible local environment.

### 💼 Business Value

> **Shift security left with automated scanning** that catches vulnerabilities before deployment. Multiple security layers (SAST, IAST, DAST, policy enforcement) reduce security incidents while maintaining development velocity.

---

## 🚀 Technology Stack

| 🔧 Tool | 🎯 Purpose | 💎 Security Value |
|---|---|---|
| **Jenkins** | CI/CD Orchestration | Automated security gate enforcement |
| **Docker** | Containerization | Reproducible builds, isolated environments |
| **Kubernetes** | Orchestration | Production-like deployment validation |
| **Trivy** | Image Scanning | OS & dependency vulnerability detection |
| **Kubesec** | Manifest Analysis | Kubernetes security best practices |
| **OPA/Conftest** | Policy Enforcement | Policy-as-code for compliance |
| **OWASP ZAP** | DAST | Runtime vulnerability scanning |
| **HashiCorp Vault** | Secret Management | Secure credential storage |

---

## 🏗️ Architecture Flow

```
┌─────────────────────────────────────────────────────────┐
│                   SOURCE CODE                           │
│              Git Repository / Workspace                 │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                 JENKINS PIPELINE                        │
├─────────────────────────────────────────────────────────┤
│  1️⃣  Checkout Code                                      │
│  2️⃣  Build Docker Image                                 │
│  3️⃣  SAST: Trivy Image Scan                             │
│  4️⃣  Policy: Kubesec + OPA/Conftest                     │
│  5️⃣  Deploy Container (local/K8s)                       │
│  6️⃣  DAST: OWASP ZAP Baseline Scan                      │
│  7️⃣  Archive Security Reports                           │
└────────────────────┬────────────────────────────────────┘
                     │
          ┌──────────┼──────────┐
          │          │          │
          ▼          ▼          ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ Docker  │ │ K8s Pod │ │ Reports │
    │Container│ │ Running │ │JSON/HTML│
    └─────────┘ └─────────┘ └─────────┘
```

---

## 🚀 Quick Start

### 📋 Prerequisites

```bash
# Verify installations
docker --version        # Docker Desktop with K8s enabled
jenkins --version       # Jenkins with Docker access
kubectl --version       # Kubernetes CLI
trivy --version        # Trivy scanner
vault --version        # HashiCorp Vault
```

### ⚡ Setup & Execution

```bash
# 1️⃣ Clone repository
git clone <your-repo-url>
cd devsecops-pipeline

# 2️⃣ Start Vault (dev mode)
docker run --cap-add=IPC_LOCK -d --name vault-dev \
  -p 8200:8200 -e 'VAULT_DEV_ROOT_TOKEN_ID=devtoken' \
  hashicorp/vault

# 3️⃣ Store secrets in Vault
export VAULT_ADDR='http://127.0.0.1:8200'
vault login devtoken
vault kv put secret/dockerhub username="your_user" password="your_pass"

# 4️⃣ Build & scan application
docker build -t devsecops-frontend:1.0 ./frontend

trivy image --format json \
  --output reports/trivy.json devsecops-frontend:1.0

# 5️⃣ Deploy to Kubernetes
kubectl apply -f frontend/k8s-deployment.yaml
kubectl get pods

# 6️⃣ Run DAST scan
docker run -d --name app -p 8080:80 devsecops-frontend:1.0

docker run --rm -v "${PWD}/reports:/zap/wrk/:rw" \
  zaproxy/zap-stable zap-baseline.py \
  -t http://host.docker.internal:8080 \
  -r /zap/wrk/zap_report.html
```

---

## 📁 Repository Structure

```
devsecops-pipeline/
├── frontend/
│   ├── index.html              # Static web application
│   ├── Dockerfile              # Container definition
│   └── k8s-deployment.yaml     # Kubernetes manifest
├── opa/
│   └── policy.rego             # OPA security policies
├── vault/
│   └── vault-config.hcl        # Vault configuration
├── reports/
│   ├── trivy.json              # Image vulnerabilities
│   ├── kubesec.json            # Manifest security score
│   └── zap_report.html         # DAST findings
└── Jenkinsfile                 # Pipeline definition
```

---

## 🔒 Security Pipeline Stages

| Stage | Tool | What It Checks | Output |
|---|---|---|---|
| **Image Scan** | Trivy | CVEs in OS packages & dependencies | JSON/HTML report with severity ratings |
| **Manifest Scan** | Kubesec | K8s security best practices | Security score + recommendations |
| **Policy Check** | OPA/Conftest | Custom policies (runAsNonRoot, etc.) | Pass/fail with violations |
| **Runtime Scan** | OWASP ZAP | Live application vulnerabilities | HTML report with attack vectors |

---

## ⚔️ Challenges & Solutions

| Challenge | Root Cause | Solution |
|---|---|---|
| **Port 8080 Conflict** | Windows service occupied port | Bind to alternate port (-p 8081:80) |
| **ImagePullBackOff** | Local image not in K8s cache | Use `minikube image load` |
| **Vault CLI Errors** | Windows PATH issues | Use `docker exec` inside container |
| **Conftest Rego Failures** | UTF-8 BOM encoding | Save files as UTF-8 without BOM |
| **Trivy HTML Format** | Deprecated flag | Use JSON + template instead |
| **ZAP Network Issues** | Docker networking | Use `host.docker.internal` |

---

## 📊 Validation Checklist

✅ **Frontend accessible**: `http://localhost:8081`  
✅ **Docker image built**: `docker images | grep devsecops-frontend`  
✅ **K8s pod running**: `kubectl get pods`  
✅ **Reports generated**: Check `reports/` directory  
✅ **Vault secrets stored**: `vault kv get secret/dockerhub`  
✅ **Jenkins pipeline passes**: All stages green  

---


## 🎯 Production Readiness Gap

| Current State | Production Requirement |
|---|---|
| Vault dev-mode (insecure) | Persistent storage + proper unsealing |
| Docker socket mounting | Dedicated agents or Docker-in-Docker |
| Manual report review | Auto-fail on critical CVEs |
| Basic ZAP scan | Authenticated scanning for full coverage |
| Local registry | Private registry with image signing |

---

## 👨‍💻 About This Project

**⚡ Built to Demonstrate Enterprise DevSecOps Practices**

This project showcases:
- **Security Integration**: Multiple scanning tools in automated pipeline
- **Policy Enforcement**: OPA/Conftest for compliance automation
- **Local Development**: Full stack runnable without cloud costs
- **Real Tradeoffs**: Documents security vs convenience decisions
- **Production Thinking**: Clear path from MVP to hardened deployment

> "Security isn't a phase—it's integrated into every step of delivery."

---

<div align="center">

⭐ **Star this repo if it helps you build secure pipelines!** ⭐

Built with Jenkins | Docker | Kubernetes | Security-First Mindset

</div>
