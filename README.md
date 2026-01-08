# Azure Hub–Spoke Architecture with VMSS

## Overview
This project implements a production-grade Azure hub–spoke architecture using Terraform.

## Architecture
- Hub–Spoke VNets
- Private VM Scale Sets
- Internal Load Balancer
- Azure Application Gateway (public ingress)
- Azure Private DNS
- NAT Gateway for outbound access
- Bastion-only administrative access

## Key Features
- No public IPs on compute
- Immutable infrastructure using cloud-init
- DNS-based service discovery
- Secure ingress and egress design

## Tech Stack
- Azure
- Terraform
- VM Scale Sets
- Application Gateway
- Private DNS

## How to Use
```bash
terraform init
terraform plan
terraform apply

<img width="900" height="579" alt="image" src="https://github.com/user-attachments/assets/2c2e51ee-0cc4-4ea5-a9be-6e9ae2e2ef2f" />

