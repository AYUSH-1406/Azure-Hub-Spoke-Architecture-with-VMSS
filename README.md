# Azure Hub–Spoke Architecture with VMSS
<img width="900" height="579" alt="image" src="https://github.com/user-attachments/assets/59dc4a7b-ec49-4e7d-abce-f4209f84cee1" />


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





