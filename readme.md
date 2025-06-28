# 🚀 Terraform AWS Infrastructure Setup

This project uses **Terraform** to provision a complete AWS infrastructure, including:

- ✅ A custom **VPC**
- ✅ Two **public subnets** in different Availability Zones
- ✅ An **Internet Gateway** and **Route Table**
- ✅ Two **EC2 instances** launched in public subnets
- ✅ Apache Web Server configured via `user_data`
- ✅ A public **Application Load Balancer** (ALB)
- ✅ Proper **security groups** and **target group attachments**
- ✅ Optional **S3 bucket** creation
- ✅ Outputs ALB DNS to access the site

---


---

## 🧰 Prerequisites

- Terraform v1.0+
- AWS CLI configured (`aws configure`)
- AWS Key Pair already created
- Ubuntu AMI ID for your region
- Proper IAM permissions to create AWS resources

---

## 🌍 What It Does

- Creates two EC2 instances (Ubuntu)
- Installs Apache using `user_data`
- Displays a webpage with the instance ID
- Creates an Application Load Balancer
- Attaches EC2s to the Target Group
- Outputs the ALB DNS name for easy access

---
