# DevOps Final Project

<div align="center">
  <img width="720" height="401" alt="Picture1" src="https://github.com/user-attachments/assets/eef9f864-d331-497e-a3c2-01836bdfb7b5" />
</div>


## Project Overview

This project showcases a fully automated **CI/CD** pipeline for a **Python** application that collects **AWS** resource data. It leverages **GitHub** for version control, **Jenkins** for continuous integration, **Docker** for containerization, **Trivy** for security scanning, and **Helm** with **ArgoCD** on a **Minikube** cluster for streamlined deployment and delivery. The pipeline covers the complete workflow from code linting and vulnerability scanning to image building, registry management, and **Kubernetes** deployment, providing a robust, end-to-end DevOps solution.

---

## Project Architecture

### Components Used

| Component                     | Purpose |
|------------------------------|--------|
| **Local PC (Windows)**       | Development machine, source code editing, and GitHub pushes |
| **VM1 (Jenkins Server)**     | CI pipeline: code linting, image building, scanning, and pushing to Docker Hub |
| **VM2 (Minikube + ArgoCD)**  | CD environment: deploys Helm chart of the app to Kubernetes cluster |

## Technologies Used

<table>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/Ubuntu.svg.png" width="50"/><br><b>Ubuntu 24.04 LTS</b></td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" width="50"/><br><b>Python 3</b></td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vscode/vscode-original.svg" width="50"/><br><b>VS Code</b></td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg" width="50"/><br><b>Git</b></td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" width="50"/><br><b>GitHub</b></td>
    <td align="center"><img src="https://helm.sh/img/helm.svg" width="50"/><br><b>Helm</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/trivy.svg" width="50"/><br><b>Trivy</b></td>
    <td align="center"><img src="https://www.vectorlogo.zone/logos/docker/docker-official.svg" width="50"/><br><b>Docker Hub</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/argocd.png" width="50"/><br><b>ArgoCD</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/Prometheus.svg.png" width="50"/><br><b>Prometheus</b></td>
  </tr>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/docker_logo_icon_170244.png" width="70"/><br><b>Docker</b></td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/jenkins/jenkins-original.svg" width="70"/><br><b>Jenkins</b></td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" width="70"/><br><b>Terraform</b></td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/kubernetes/kubernetes-plain.svg" width="50"/><br><b>Minikube / K8s</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/vmware.svg" width="50"/><br><b>VMware</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/grafana.svg" width="50"/><br><b>Grafana</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/thanos.png" width="50"/><br><b>Thanos</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/harbor.png" width="50"/><br><b>Harbor</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/ansible.png" width="50"/><br><b>Ansible</b></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Philiprime97/DevOps_Project/main/images/aws.svg.svg" width="50"/><br><b>AWS</b></td>
  </tr>
</table>

## Project Diagram
![DevOps Project 1 Architecture Diagram](https://github.com/user-attachments/assets/392ead60-0b86-4b66-8374-5ca8671352ea)

---

## Operating System – Ubuntu 24.04 LTS
Both virtual machines were configured using Ubuntu 24.04 LTS as the operating system.
This version offers strong long-term support, high stability, and compatibility with most DevOps tools including Jenkins, Docker, and Kubernetes.
Its lightweight and secure design made it ideal for hosting the pipeline infrastructure.

![vm1 and vm2](https://github.com/user-attachments/assets/7dd5ad7a-4c50-4267-8ff7-a4f30da52c3c)


## Development Environment – Visual Studio Code
All Python application development and Git version control were performed using **Visual Studio Code (VSC)** on my local Windows machine.


## 1. Application Setup

### Python Application

The application is a **Python-based AWS resource fetcher** built with **Boto3** SDK.
It connects to an AWS account, retrieves data (like EC2 instances, S3 buckets, and regions), and dynamically generates an **HTML page with a custom-table** displaying all collected information.

This HTML page is later served and packaged inside a Docker container, becoming the deployable artifact in the CI/CD pipeline.


### Local Setup


1. Create virtual environment
```bash
python -m venv venv
source venv/bin/activate  # (On Windows: venv\Scripts\activate)
```
2. Install dependencies
```bash
pip install -r requirements.txt
```

3. Push to GitHub
```bash
git init
git remote add origin https://github.com/<your-username>/<repo-name>.git
git add .
git commit -m "Initial commit"
git push origin main
```

### AWS Credentials

AWS access is handled securely through environment variables:
```bash
export AWS_ACCESS_KEY_ID=<your-access-key>
export AWS_SECRET_ACCESS_KEY=<your-secret-key>
export AWS_DEFAULT_REGION=<your-region>
```
>⚠️ Never hardcode AWS credentials inside your code or commit them to GitHub.


### Dockerization

To containerize the application, a lightweight Dockerfile was created :
```bash
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt
COPY . .
EXPOSE 5001
CMD ["python", "app.py"]
```
The Jenkins pipeline builds this image, scans it for vulnerabilities using Trivy, and pushes it to Docker Hub for deployment.

---

##  2. CI Setup – Jenkins Server (VM1)
###  1. Install Jenkins
```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

### Access Jenkins UI:
- http://(VM1-IP):8080

### Jenkins Login:
- **Username**: admin
- **Password**: type this command in the terminal on **VM1** to fetch the initial password

`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

![jenkins ui](https://github.com/user-attachments/assets/d2c83412-2a55-40dc-bb2d-72437b4042c3)

###  2. Jenkins Plugins:
- **Pipeline: Stage View** - Enables structured Jenkins pipelines with stages and steps for CI/CD workflows.

![STAGE VIEW1](https://github.com/user-attachments/assets/207fe00b-69ae-49b3-8b09-60feb1c9785b)

- **Blue Ocean** - Provides a modern, visual interface to easily monitor pipeline stages and build history.

![BLUE OCEAN1](https://github.com/user-attachments/assets/114d46aa-a5f1-446e-9d26-9288574362ff)

- **HTML Publisher plugin** - Allows Jenkins to display HTML reports as build artifacts directly in the interface.

![reports](https://github.com/user-attachments/assets/ab18b1b0-fcd3-49d1-bae2-81cc8ebb9f1b)

####  Jenkins Credentials:
**DockerHub credentials( ID: dockerhub )** - Used securely by the pipeline to log in and push Docker images without exposing passwords.

![credentiols](https://github.com/user-attachments/assets/20246539-e18e-448b-99c5-2616f3825b35)

### 3. Jenkins Pipeline
The Jenkinsfile automates the following CI/CD stages:

| Step | Description |
|------|-------------|
| 1 | Checks if Docker Installed |
| 2 | Checks if Trivy Installed |
| 3 | Clone the repository from GitHub |
| 4 | Run `flake8` for linting |
| 5 | Scan source code with Trivy |
| 6 | Build Docker image |
| 7 | Scan Docker image with Trivy |
| 8 | Login to Docker Hub |
| 9 | Push image to Docker Hub |
| 10 | Cleanup temporary containers/images |



### 4. HTML Reports and Jenkins Artifacts

During the Jenkins pipeline execution, three reports were generated:
- **flake8-report.txt**
- **trivy-source-report.html**
- **trivy-image-report.html**

Each report was stored as a **Jenkins artifact**, allowing review after each build.
The reports used a **custom HTML template** downloaded from the prohect repository during the pipeline run to produce a clean, professional overview.


### 5. Enabling HTML Rendering in Jenkins

By default, Jenkins blocks inline HTML and JavaScript for security.
To display these HTML reports directly within Jenkins:

- Install the **“HTML Publisher Plugin.”**

- Opened the Jenkins **Script Console (Manage Jenkins → Script Console)**.

- Executed the following command to disable the restrictive CSP policy:
```bash
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")
```
This allowed Jenkins to render inline HTML safely and display all reports in the browser directly from the build artifacts.

![script console](https://github.com/user-attachments/assets/76193621-bbae-46ab-b113-ac1561c6eba7)

---

## 3. CD Setup – Minikube + ArgoCD (VM2)
### 1. Install Minikube
```bash
sudo apt update -y
sudo apt install -y curl apt-transport-https virtualbox virtualbox-ext-pack
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
### 2. Start Minikube
```bash
minikube start --driver=docker
```
### 3. Enable Ingress
```bash
minikube addons enable ingress
```
### 4.  Install kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 5. Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
### 6. Port-Forward ArgoCD:
```bash
kubectl port-forward svc/argocd-server -n argocd 8081:443
```

### 7. Access ArgoCD UI:
- http://(VM2-IP):8081

### 8. ArgoCD Login:
- **Username**: admin
- **Password**: type this command in the terminal on **VM2** to fetch the initial password

`kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d`

![argocd ui](https://github.com/user-attachments/assets/b8db2130-5cd1-49d3-bf02-3ddec5f543ee)

### 9. Helm Chart Deployment

Your Helm chart (stored in GitHub) defines:
- Deployment
- Service (type: NodePort or LoadBalancer)
- ingress

### 10. Connect ArgoCD App

In ArgoCD UI → “New App” →

- Repository URL: `https://github.com/Philiprime97/myapp-helm.git`
- Path: `.`
- Cluster: `https://kubernetes.default.svc`
- Namespace: `aws`
- Then click Sync → ArgoCD will deploy automatically.

![argocd deployment](https://github.com/user-attachments/assets/394ae234-301c-4a0a-8296-a7c06568edf4)

### 11. Check the pod's svc port
```bash
kubectl get svc -n aws
```

![svc port](https://github.com/user-attachments/assets/05bd19a4-d810-4468-b28b-a8d285621eb2)

### 12. Access the Application

Since Minikube runs locally, port-forward on VM2 :
```bash
minikube tunnel
kubectl port-forward svc/aws 5001:5001 -n aws --address=0.0.0.0
```

Now access the app from your local windows pc browser:
- http://(VM2-IP):5001
  
![app-ui1](https://github.com/user-attachments/assets/6e1e0fe6-7faa-4ea7-978f-cc3a6606bb85)

![app-ui2](https://github.com/user-attachments/assets/0ed93253-7ab5-4b9b-8ddc-c2907bbc9def)

---
## 4. Monitorng Setup – Prometheus ,Grafana and Thanos on Minikube (VM2)
In this workflow, we will extend **Prometheus** monitoring with **Thanos** to enable long-term, centralized storage and global querying of metrics. To achieve this, we will create an **S3 bucket** for storing Prometheus blocks, set up a dedicated **IAM user** with the necessary S3 permissions, and configure Prometheus with a **Thanos sidecar** to upload data and expose gRPC endpoints. We will deploy **Thanos components—including Query, Compactor, and optionally Store Gateway** to aggregate live and historical metrics. Finally, **Grafana** will be configured to use **Thanos Query** as a datasource, allowing dashboards to display both live metrics from Prometheus and historical data from S3. Required elements include a Kubernetes cluster, Prometheus deployment, S3 bucket and credentials, **Thanos manifests** or **Helm values**, and **Grafana** connected to **Thanos Query**.

________________________________________
## Thanos Architecture — Short Overview

Thanos extends Prometheus into a highly available, long-term, global monitoring system.
It adds several components around Prometheus to solve major limitations like scalability, HA, and long-term storage.
Prometheus by itself stores metrics locally on disk and can only collect and query data from a single server. Thanos solves these limitations by introducing multiple components that work together around Prometheus.

<img width="1601" height="860" alt="97e49180-661b-11e9-9882-fdc44b74debd" src="https://github.com/user-attachments/assets/44d8adf1-aaa8-4832-8dd9-3437b59785c9" />

## How Thanos Works

### 1. Prometheus (Scraper + TSDB)
Prometheus continues to scrape targets and stores time-series data locally in its **TSDB (Time Series Database)**.
Nothing changes in how Prometheus collects metrics.

### 2. Thanos Sidecar
A sidecar container runs inside the same Prometheus Pod.
It performs **two major functions**:
 * Exposes Prometheus data over gRPC for Thanos Query (live data access).
 * Optionally uploads Prometheus TSDB blocks to an object store (S3, GCS, MinIO) for long-term storage.

### 3. Object Storage (S3)
Instead of keeping old metrics only on the Prometheus disk, Thanos stores blocks in an S3 bucket.
This provides:
 * Unlimited retention
 * Centralized storage
 * Data durability

### 4. Thanos Store Gateway
A component that reads historical data **directly from S3** and exposes it to Thanos Query.
It does **not** scrape or collect metrics – it only serves compressed blocks stored in the bucket.

### 5. Thanos Compactor
Optimizes and organizes S3 data by:
 * Downsampling old metrics
 * Merging small blocks into larger ones
 * Enforcing retention policies

This reduces S3 costs and improves query performance.

### 6. Thanos Query
The central aggregator that combines:
 * **Live data** from Prometheus (via Sidecar)
 * **Historical data** from S3 (via Store Gateway)

### 7. Grafana
Instead of connecting directly to Prometheus, Grafana connects to **Thanos Query**, allowing dashboards to show:
 * Real-time data from Prometheus
 * Long-term historical data from S3
 * Data from multiple Prometheus instances (multi-cluster monitoring)
________________________________________

## Repository Structure
```bash
/monitoring
  ├─ thanos-compactor.yaml      # Thanos Compactor Deployment
  ├─ thanos-query.yaml          # Thanos Query Deployment
  ├─ thanos-secret.yaml         # Secret containing S3 bucket configuration
  ├─ thanos-store.yaml          # Thanos Store Gateway Deployment
  ├─ values.yaml                # Prometheus config + Thanos Sidecar configuration
```
________________________________________
## 1. AWS Setup — S3 Bucket + IAM User
### 1. Create an S3 bucket
Example name:
```bash
thanos-metrics-lab
```
### 2. Create a dedicated IAM user
Example name:
```bash
thanos-storage-user
```
Enable programmatic access.
This user will authenticate from:
 * Thanos Sidecar
 * Thanos Store
 * Thanos Compactor
### 3. Attach the minimum required IAM policy
Give the user only access to the specific bucket:

________________________________________
## 2. Clone the Repository (Manual Deployment Required)
We deploy manually (not via ArgoCD) because the AWS credentials must be stored locally using Kubernetes Secrets — never stored inside the repo, as ArgoCD cannot sync private secrets.
```bash
git clone https://github.com/your-username/your-repo.git
cd monitoring
```
________________________________________
## 3. Update Helm Repositories
```bash
helm repo update
```
________________________________________
## 4. Install Prometheus + Grafana
Prometheus with Thanos sidecar
```bash
helm upgrade --install prometheus prometheus-community/prometheus -f values.yaml -n monitoring
```

Grafana
```bash
helm upgrade --install grafana grafana/grafana -n monitoring
```
________________________________________
## 5. Apply Thanos Configuration and Components
### 1. Create Kubernetes Secret for S3
Your thanos-secret.yaml must contain:
 * Access_Key
 * Secret_Key
 * Bucket_Name
 * Region

Apply it:
```bash
kubectl apply -f thanos-secret.yaml
```
### 2. Deploy Thanos Query
```bash
kubectl apply -f thanos-query.yaml
```
### 3. Deploy Thanos Store Gateway
```bash
kubectl apply -f thanos-store.yaml
```
### 4. Deploy Thanos Compactor
```bash
kubectl apply -f thanos-compactor.yaml
```
________________________________________
## 6. Verify Deployments
```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```
You should see:
 * Prometheus
 * Thanos Sidecar (inside Prometheus pod)
 * Thanos Query
 * Thanos Store Gateway
 * Thanos Compactor
 * Grafana

If services are not using 'NodePort', Convert them manually:
```bash
kubectl edit svc <service-name> -n monitoring
```
Change:
```bash
type: ClusterIP
```
To:
```bash
type: NodePort
```
________________________________________
## 7. Configure Grafana
After Grafana is installed, you need to access its web UI to add the Thanos datasource.

If your Grafana Service is configured as NodePort:
```bash
kubectl get svc grafana -n monitoring
```
Output example:
```bash
grafana   NodePort   10.96.12.22   <none>   80:32188/TCP
```
Run Port-Forward:
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```
Get the service details:
### 1.	Open Grafana in browser
http://VM_IP:3000

### 2. Grafana Login

Default credentials:

 * **Username**: admin

 * **Password**: admin (or auto-generated — run below to get it)
 ```bash
 kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```
Get password:
### 3.	Go to Configuration → Data Sources
### 4.	Add a new datasource:
 * **Type**: Prometheus
 * **URL**: http://<THANOS_QUERY_NODEPORT_IP>:<NODEPORT>

This makes Grafana read:
 * **Live metrics** → from Prometheus (via sidecar)
 * **Historical metrics** → from S3 (via Store Gateway)
 
 Import dashboards or build custom ones as needed.
________________________________________

## Conclusion

This project showcases a complete CI/CD workflow integrating:

- Source control with GitHub
- Continuous Integration with Jenkins
- Containerization with Docker
- Security Scanning with Trivy
- Continuous Delivery with ArgoCD & Helm
- Kubernetes orchestration on Minikube

