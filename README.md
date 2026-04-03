# PACS — Secure Cloud Architecture on AWS

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws)
![VPC](https://img.shields.io/badge/VPC-10.0.0.0%2F16-blue)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

A hands-on AWS infrastructure project implementing a secure, segmented cloud architecture using industry best practices. Built as part of an L3 Cloud Infrastructure & Cybersecurity curriculum.

---

## Overview

PACS (Projet Architecture Cloud Sécurisée) demonstrates a production-ready network architecture on AWS, featuring public/private subnet segmentation, a Bastion Host for secure administrative access, and a full security and monitoring stack.

---

## Architecture Diagram

```
                        INTERNET
                            │
                    ┌───────▼────────┐
                    │ Internet Gateway│
                    └───────┬────────┘
                            │
            ┌───────────────▼──────────────────┐
            │         VPC  10.0.0.0/16          │
            │                                   │
            │  ┌────────────────────────────┐   │
            │  │  Public Subnet 10.0.2.0/24 │   │
            │  │   ┌──────────────────┐     │   │
            │  │   │  EC2 Bastion Host│     │   │
            │  │   └──────────────────┘     │   │
            │  │   ┌──────────────────┐     │   │
            │  │   │   NAT Gateway    │     │   │
            │  │   └──────────────────┘     │   │
            │  └────────────────────────────┘   │
            │                                   │
            │  ┌────────────────────────────┐   │
            │  │ Private Subnet 10.0.1.0/24 │   │
            │  │   ┌──────────────────┐     │   │
            │  │   │  EC2 + Nginx     │     │   │
            │  │   └──────────────────┘     │   │
            │  └────────────────────────────┘   │
            └───────────────────────────────────┘
```

---

## AWS Services Used

| Service | Role |
|---|---|
| **VPC** | Isolated private network (10.0.0.0/16) |
| **Public Subnet** | Hosts the Bastion Host and NAT Gateway |
| **Private Subnet** | Hosts the application server (EC2 + Nginx) |
| **Internet Gateway** | Allows inbound/outbound traffic to the public subnet |
| **NAT Gateway** | Allows private instances to reach the internet (outbound only) |
| **EC2 (Bastion Host)** | Secure administrative jump server (SSH gateway) |
| **EC2 + Nginx** | Web/application server in the private subnet |
| **Route Tables** | Controls traffic routing between subnets |
| **Security Groups** | Stateful firewall rules per instance |
| **IAM Roles** | Least-privilege permissions for EC2 instances |
| **EBS Encryption** | Data-at-rest encryption via snapshot + KMS |
| **AWS CloudTrail** | Full audit log of all API calls (stored in S3) |
| **VPC Flow Logs** | Network traffic monitoring sent to CloudWatch |

---

## Network Design

### IP Addressing

| Component | CIDR Block |
|---|---|
| VPC | 10.0.0.0/16 |
| Public Subnet | 10.0.2.0/24 |
| Private Subnet | 10.0.1.0/24 |
| Bastion Host (private IP) | 10.0.2.248 |
| App Server (private IP) | 10.0.1.235 |

### Routing

| Route Table | Destination | Target |
|---|---|---|
| Public-RT | 0.0.0.0/0 | Internet Gateway |
| Public-RT | 10.0.0.0/16 | local |
| Private-RT | 0.0.0.0/0 | NAT Gateway |
| Private-RT | 10.0.0.0/16 | local |

### Security Group Rules

**Bastion Host**
| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | Admin IP only (`x.x.x.x/32`) |

**App Server (Private)**
| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | Bastion private IP (10.0.2.248/24) |
| HTTP | TCP | 80 | Bastion private IP (10.0.2.248/24) |

---

## Deployment Steps

### Prerequisites
- AWS account with appropriate permissions
- PuTTY (Windows) or any SSH client
- AWS CLI configured (optional)

### Phase 1 — Network Foundation
1. Create a VPC with CIDR `10.0.0.0/16`
2. Create two subnets:
   - Public: `10.0.2.0/24`
   - Private: `10.0.1.0/24`
3. Create and attach an Internet Gateway to the VPC
4. Create a NAT Gateway in the public subnet
5. Configure route tables (see `infrastructure/routing.md`)

### Phase 2 — EC2 Instances
1. Launch Bastion Host in the public subnet (Ubuntu, t3.micro)
2. Launch App Server in the private subnet (Ubuntu, t3.micro)
3. Configure security groups (SSH restricted to admin IP for Bastion)
4. Connect to Bastion via PuTTY, then SSH into private instance through tunnel

### Phase 3 — Security & Monitoring
1. Create IAM Role with `CloudWatchAgentServerPolicy` and attach to both instances
2. Enable EBS encryption via snapshot copy with KMS key
3. Create S3 bucket for CloudTrail logs (see `policies/s3-cloudtrail-policy.json`)
4. Enable CloudTrail (multi-region, log file validation enabled)
5. Enable VPC Flow Logs → CloudWatch Logs

### Nginx Installation (on private instance)
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```
See full script: `scripts/install-nginx.sh`

---

## Security Highlights

- **No direct internet access** to the application server — all admin access goes through the Bastion Host
- **SSH restricted** to a single administrator IP on the Bastion
- **Data at rest encrypted** — EBS volumes encrypted using AWS KMS
- **Full audit trail** — every AWS API call logged via CloudTrail and stored in S3
- **Network traffic logged** — VPC Flow Logs sent to CloudWatch for anomaly detection
- **Least privilege IAM** — EC2 instances only have the permissions they need

---

## Suggested Improvements

| Improvement | Benefit |
|---|---|
| Replace Bastion SSH with **AWS SSM** | No port 22 exposure, full session audit |
| Add **Application Load Balancer** | Traffic distribution, health checks |
| Add **Auto Scaling Group** | Automatic scaling based on CPU load |
| Add **AWS WAF** | Layer 7 protection against SQLi, XSS, bots |
| Migrate to **3-Tier Architecture** | Full production-ready infrastructure |

---

## Project Structure

```
pacs-secure-cloud-architecture/
├── README.md
├── .gitignore
├── docs/
│   └── PACS.pdf                    # Full project presentation (FR)
├── infrastructure/
│   ├── vpc.md                      # VPC and subnet setup
│   ├── ec2.md                      # EC2 instance configuration
│   └── routing.md                  # Route tables and NAT Gateway
├── scripts/
│   └── install-nginx.sh            # Nginx installation script
└── policies/
    ├── iam-role-ec2.json           # IAM trust policy for EC2
    └── s3-cloudtrail-policy.json   # S3 bucket policy for CloudTrail
```

---

## Author

**Louboulat Milandou Justesse**
Cloud | Networking | Linux
Dakar, Senegal — 2026

---
