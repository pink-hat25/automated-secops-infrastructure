# Automated SecOps Infrastructure

![OpenTofu](https://img.shields.io/badge/IaC-OpenTofu-blue?style=for-the-badge&logo=opentofu)
![Ansible](https://img.shields.io/badge/Automation-Ansible-EE0000?style=for-the-badge&logo=ansible)
![AlmaLinux 9](https://img.shields.io/badge/OS-AlmaLinux_9-0F2B48?style=for-the-badge&logo=almalinux)
![k3s](https://img.shields.io/badge/Orchestration-k3s-FFC61C?style=for-the-badge&logo=k3s)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?style=for-the-badge&logo=prometheus)
![Grafana](https://img.shields.io/badge/Visualization-Grafana-F46800?style=for-the-badge&logo=grafana)

A production-ready, GitOps-compliant automated SecOps infrastructure deployed on Enterprise Linux (**AlmaLinux 9**) over **KVM/libvirt** virtualization. This project uses **OpenTofu** for Infrastructure as Code (IaC), **Ansible** for automated security hardening and stack provisioning, and **k3s** for lightweight Kubernetes orchestration integrated with a full monitoring stack.

---

## 🏗️ Architecture Overview

```
+-----------------------------------------------------------------------------------+
| Host System: Debian Linux (KVM / QEMU / libvirt Hypervisor)                       |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  | VM: secops-node-01 (AlmaLinux 9) [192.168.122.165]                          |  |
|  |                                                                             |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  |  | Security & Hardening: SSH Key-Only | Firewalld | Fail2ban | SELinux |  |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  |  | Container Engine: k3s (Lightweight Kubernetes) + Helm                 |  |  |
|  |  |  +-----------------------------------------------------------------+  |  |  |
|  |  |  | Monitoring Stack: Prometheus + Grafana (NodePort :30000)        |  |  |  |
|  |  |  +-----------------------------------------------------------------+  |  |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  +-----------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------+
        ^                                                                  ^
        | (Provisioning via libvirt)                                       | (Config & Hardening)
   [ OpenTofu ]                                                       [ Ansible ]
        ^                                                                  ^
        +----------------------- [ GitHub Actions CI/CD ] -----------------+
```

---

## ✨ Key Features

- **Declarative Virtualization**: Fully automated VM lifecycle management using OpenTofu and Cloud-Init on KVM/libvirt.
- **Enterprise OS Hardening**: Automated baseline hardening according to SecOps standards:
  - SSH key-based authentication with password login disabled.
  - SELinux in `Enforcing` mode.
  - Active firewall protection via `firewalld` with minimal port exposure.
  - Automated intrusion prevention using `fail2ban` (EPEL package).
- **Lightweight Kubernetes (k3s)**: Automated cluster initialization with container storage and networking preconfigured.
- **Observability Stack**: Integrated Prometheus metric collection and Grafana visualization dashboard accessible via NodePort (`30000`).
- **GitOps & CI/CD Ready**: Integrated workflow via GitHub Actions with self-hosted runners.

---

## 🛠️ Tech Stack

| Domain | Technology |
| :--- | :--- |
| **Hypervisor** | KVM / QEMU / libvirt (Debian Host) |
| **Operating System** | AlmaLinux 9 (Cloud Image) |
| **Infrastructure as Code** | OpenTofu |
| **Config Management** | Ansible |
| **Container Engine** | k3s (Kubernetes), Docker CLI |
| **Monitoring** | Prometheus, Grafana, Helm |
| **CI/CD** | GitHub Actions |

---

## 📁 Repository Structure

```
automated-secops-infrastructure/
├── .github/
│   └── workflows/
│       └── infra-pipeline.yml    # CI/CD pipeline definition
├── ansible/
│   ├── ansible.cfg              # Ansible configuration
│   ├── inventory.ini            # Target host inventory
│   ├── hardening.yml            # Security baseline playbook
│   └── deploy_stack.yml         # k3s & monitoring stack playbook
├── tofu/
│   ├── main.tf                  # Libvirt VM & network configuration
│   └── cloud_init.cfg           # Cloud-init template for AlmaLinux 9
├── .gitignore
└── README.md
```

---

## 🚀 Quick Start Guide

### Prerequisites

Ensure your host system meets the following requirements:
- Linux Host (Debian/Ubuntu/RHEL) with KVM/libvirt installed and enabled.
- OpenTofu >= v1.6.0
- Ansible >= 2.15
- GitHub CLI (`gh`) for GitOps setup

---

### Step 1: Provision Infrastructure (OpenTofu)

1. Navigate to the `tofu/` directory:
   ```bash
   cd tofu/
   ```

2. Initialize and apply the OpenTofu configuration:
   ```bash
   tofu init
   tofu plan
   tofu apply -auto-approve
   ```

*This provisions the AlmaLinux 9 VM (`secops-node-01`) at IP `192.168.122.165`.*

---

### Step 2: Security Hardening & Stack Provisioning (Ansible)

1. Navigate to the `ansible/` directory:
   ```bash
   cd ../ansible/
   ```

2. Execute the security hardening playbook:
   ```bash
   ansible-playbook hardening.yml
   ```

3. Deploy k3s, Helm, Prometheus, and Grafana:
   ```bash
   ansible-playbook deploy_stack.yml
   ```

---

### Step 3: Verification & Access

- **SSH Access**:
  ```bash
  ssh sysadmin@192.168.122.165
  ```

- **Grafana Dashboard**:
  Open your web browser and navigate to:
  `http://192.168.122.165:30000`

- **Cluster Health Verification**:
  ```bash
  ssh sysadmin@192.168.122.165 "sudo kubectl get nodes -o wide"
  ssh sysadmin@192.168.122.165 "sudo kubectl get pods -A"
  ```

---

## 🛡️ Backup & Restoration (KVM Snapshots)

To create an instant snapshot baseline of the fully configured state:

```bash
# Create Snapshot
sudo virsh snapshot-create-as --domain secops-node-01 \
  --name baseline-k3s-ready \
  --description "K3s, Prometheus, and Grafana fully operational"

# List Snapshots
sudo virsh snapshot-list secops-node-01

# Revert to Snapshot
sudo virsh snapshot-revert --domain secops-node-01 --snapshotname baseline-k3s-ready
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.