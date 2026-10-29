# Disaster Recovery & Rollback Platform

## Overview
A hands-on AWS and Kubernetes project demonstrating S3-based backup and restore, Kubernetes deployment rollback, recovery validation, and incident documentation.

## Technology Stack
- AWS EKS
- Amazon S3 with versioning and encryption
- Terraform
- Kubernetes
- AWS CLI
- Bash scripting
- Git and GitHub

## Architecture
- A dedicated EKS cluster hosts the sample application.
- An encrypted, private S3 bucket stores timestamped backup artifacts.
- S3 versioning preserves prior object versions.
- Kubernetes rollout history supports application deployment rollback.
- Bash scripts automate backup, restore, and rollback operations.

## Repository Structure
- `terraform/` — AWS infrastructure
- `k8s/` — Kubernetes application manifests
- `scripts/` — Backup, restore, and rollback scripts
- `backups/` — Non-sensitive test fixtures
- `incidents/` — Recovery reports and troubleshooting notes

## Key Tests
1. Upload sample state files to S3.
2. Delete a local test file and restore it from S3.
3. Deploy an invalid container image.
4. Diagnose the failed rollout.
5. Roll back to the previous working revision.
6. Record recovery time and verification results.

## Limitations
This learning project demonstrates application-artifact recovery and Kubernetes deployment rollback. It does not implement full EKS cluster backup, live database recovery, automatic regional failover, or guaranteed recovery objectives.

## Security
Terraform state and variable files containing sensitive information must not be committed. The S3 bucket blocks public access and enables encryption and versioning.

## Cleanup
Use `terraform destroy` after reviewing the destruction plan. Verify that the project's EKS cluster, worker nodes, NAT Gateway, Elastic IP, and S3 bucket are removed.
