# DevOps Final Project


## 📘 Project Overview

This project demonstrates a **complete CI/CD pipeline** for a Python-based application that fetches resource data from an AWS account.  
It integrates **GitHub, Jenkins, Docker, Trivy, Helm, ArgoCD, and Minikube** to automate build, test, security scanning, deployment, and delivery processes.

---

## Project Architecture

### Components Used

| Component                     | Purpose |
|------------------------------|--------|
| **Local PC (Windows)**       | Development machine, source code editing, and GitHub pushes |
| **VM1 (Jenkins Server)**     | CI pipeline: code linting, image building, scanning, and pushing to Docker Hub |
| **VM2 (Minikube + ArgoCD)**  | CD environment: deploys Helm chart of the app to Kubernetes cluster |

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
export AWS_DEFAULT_REGION=eu-central-1
```
⚠️ Never hardcode AWS credentials inside your code or commit them to GitHub.


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

### ArgoCD Login:
- Username: admin
- Password: type this command in the terminal on **VM1**

`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

![jenkins ui](https://github.com/user-attachments/assets/d2c83412-2a55-40dc-bb2d-72437b4042c3)

###  2. Jenkins Plugins:
- **Pipeline: Stage View** - Enables structured Jenkins pipelines with stages and steps for CI/CD workflows.

![STAGE VIEW](https://github.com/user-attachments/assets/18de0497-c93f-47cc-9fab-e52ad297c6bd)

- **Blue Ocean** - Provides a modern, visual interface to easily monitor pipeline stages and build history.

![BLUE OCEAN](https://github.com/user-attachments/assets/ab496ebc-b945-4c5c-bdab-37e7b3359fb8)

- **HTML Publisher plugin** - Allows Jenkins to display HTML reports as build artifacts directly in the interface.

![reports](https://github.com/user-attachments/assets/ab18b1b0-fcd3-49d1-bae2-81cc8ebb9f1b)

####  Jenkins Credentials:
**DockerHub credentials( ID: dockerhub )** - Used securely by the pipeline to log in and push Docker images without exposing passwords.

![credentiols](https://github.com/user-attachments/assets/20246539-e18e-448b-99c5-2616f3825b35)

### 3. Jenkins Pipeline
The Jenkinsfile automates the following CI/CD stages:

| Step | Description |
|------|-------------|
| 1 | Clone the repository from GitHub |
| 2 | Run `flake8` for linting |
| 3 | Scan source code with Trivy |
| 4 | Build Docker image |
| 5 | Scan Docker image with Trivy |
| 6 | Login to Docker Hub |
| 7 | Push image to Docker Hub |
| 8 | Cleanup temporary containers/images |



### 📊 4. HTML Reports and Jenkins Artifacts

During the Jenkins pipeline execution, three reports were generated:
- **flake8-report.txt**
- **trivy-source-report.html**
- **trivy-image-report.html**

Each report was stored as a **Jenkins artifact**, allowing review after each build.
The reports used a **custom HTML template** downloaded from the prohect repository during the pipeline run to produce a clean, professional overview.


### 🌐 5. Enabling HTML Rendering in Jenkins

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

## ☸️ 3. CD Setup – Minikube + ArgoCD (VM2)
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
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 7. Access ArgoCD UI:
- http://(VM2-IP):8080

### 8. ArgoCD Login:
- Username: admin
- Password: type this command in the terminal 

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

Since Minikube runs locally:
```bash
minikube tunnel
kubectl port-forward svc/aws 5000:5001 -n aws --address=0.0.0.0
```

Now access the app from your browser:
- http://(VM2-IP):5000

![AWS Resource Viewer - Output](https://github.com/user-attachments/assets/3a3884d6-9cbc-40b2-8eca-f1883a0b970e)

---

## 🏁 Conclusion

This project showcases a complete CI/CD workflow integrating:

- Source control with GitHub
- Continuous Integration with Jenkins
- Containerization with Docker
- Security Scanning with Trivy
- Continuous Delivery with ArgoCD & Helm
- Kubernetes orchestration on Minikube

