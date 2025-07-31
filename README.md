# SkillBoost Analytics Platform – Terraform Infrastructure

This repository provisions the AWS infrastructure for the SkillBoost Analytics data pipeline using Terraform.

---

## 🚀 Architecture Overview

This project sets up a batch data pipeline with:

- **RDS (external - Dev Team AWS Account)**
- **AWS Glue**: Extracts data from RDS → Redshift `raw` schema
- **Amazon Redshift**:
  - `raw` schema (bronze)
  - `curated` schema (silver)
  - `presentation` schema (gold)
- **AWS Step Functions**: Orchestrates Glue Job + Redshift stored procedures

---

## 📁 Project Structure

| File                | Description |
|---------------------|-------------|
| `main.tf`           | Includes all module files |
| `provider.tf`       | AWS provider and region config |
| `variables.tf`      | Project variables |
| `outputs.tf`        | Redshift and Step Function endpoints |
| `iam.tf`            | IAM roles for Glue and Step Functions |
| `glue.tf`           | Glue Job definition |
| `connection.tf`     | JDBC connection to Dev RDS |
| `redshift.tf`       | Redshift schemas and optional cluster |
| `stepfunctions.tf`  | Step Function to orchestrate ETL |
| `scripts/`          | Reference ETL scripts (optional) |

---

## ✅ Prerequisites

- Terraform CLI installed
- AWS credentials set via CLI or profile
- Access to the RDS instance (VPC + SG config required)

---

## 🔧 Usage

### 1. Clone the repo
```bash
git clone https://github.com/yourusername/skillboost-analytics-iac.git
cd skillboost-analytics-iac
