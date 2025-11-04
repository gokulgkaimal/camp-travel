# 🏕️ Camp-Travel — End-to-End DevOps Deployment of a Full-Stack Travel Application  

*(A Flask + React Application Deployed on AWS with EKS, Terraform, Jenkins, SonarQube, Trivy, ECR & Prometheus/Grafana)*  

---

## 📖 Overview  

**Camp-Travel** is a **full-stack travel booking and exploration web application** consisting of:  
- **Frontend:** React (Vite)  
- **Backend:** Flask (Python)  


The entire application is **containerized**, pushed to **Amazon ECR**, deployed on **EKS (Kubernetes)** using **Terraform**, and continuously integrated/delivered via **Jenkins**.  
This project demonstrates **complete CI/CD automation** with **quality analysis (SonarQube)**, **security scanning (Trivy)**, and **monitoring (Prometheus + Grafana)** — all running on AWS.  

---

## 🧱 Architecture  

Developer → GitHub → Jenkins → SonarQube → Trivy → AWS ECR → EKS → Prometheus → Grafana
   |
Terraform (Infrastructure as Code)

**Features**

Modern React frontend and Flask REST API backend

Containerized using Docker

CI/CD Pipeline via Jenkins

Static Code Analysis with SonarQube

Vulnerability Scanning with Trivy

Automated Deployment to AWS EKS

Infrastructure as Code using Terraform

Monitoring via Prometheus and Grafana

## 🏕️ Camp-Travel Homepage
![Camp Travel Homepage](./screenshots/camp-travel-homepage.png)

## 🔐 Login Page
![Camp Travel Login Page](./screenshots/camp-travel-login-page.png)


☁️ **DevOps & Deployment*

Tools & Services Used

Docker

Jenkins (CI/CD)

Terraform (IaC)

AWS EKS (Elastic Kubernetes Service)

AWS ECR (Container Registry)

SonarQube (Code Quality)

Trivy (Image Scan)

Prometheus + Grafana (Monitoring)

**Infrastructure & Installation (AWS + K8s + DevOps Tools)**
1️⃣ AWS Setup

Created a custom VPC using Terraform with 2–3 public subnets across AZs.

Provisioned:

EKS Cluster with managed node group (m7i-flex.large Instance)

ECR Repositories: camp-travel-frontend, camp-travel-backend

EC2 Tools Instance (m7i-flex.large Instance) for Jenkins, SonarQube, Trivy, Prometheus, Grafana


