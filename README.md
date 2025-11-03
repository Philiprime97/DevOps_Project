# DevOps Final Project


## 📘 Project Overview

This project demonstrates a **complete CI/CD pipeline** for a Python-based application that fetches resource data from an AWS account.  
It integrates **GitHub, Jenkins, Docker, Trivy, Helm, ArgoCD, and Minikube** to automate build, test, security scanning, deployment, and delivery processes.

---

## 🧩 Project Architecture

### Components Used

| Component                     | Purpose |
|------------------------------|--------|
| **Local PC (Windows)**       | Development machine, source code editing, and GitHub pushes |
| **VM1 (Jenkins Server)**     | CI pipeline: code linting, image building, scanning, and pushing to Docker Hub |
| **VM2 (Minikube + ArgoCD)**  | CD environment: deploys Helm chart of the app to Kubernetes cluster |

---

## 🐧 Operating System – Ubuntu 24.04 LTS
Both virtual machines were configured using Ubuntu 24.04 LTS as the operating system.
This version offers strong long-term support, high stability, and compatibility with most DevOps tools including Jenkins, Docker, and Kubernetes.
Its lightweight and secure design made it ideal for hosting the pipeline infrastructure.


## 💻 Development Environment – Visual Studio Code
All Python application development and Git version control were performed using **Visual Studio Code (VSC)** on my local Windows machine.


## ⚙️ 1. Application Setup

### 🐍 Python Application

The app fetches AWS resource data using **Boto3**.

### 🧱 Local Setup


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
---

## ⚙️ 2. CI Setup – Jenkins Server (VM1)
### 🧰 1. Install Jenkins
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
http://(vm1-ip):8080

### 🧩 2. Jenkins Plugins:
- Pipeline: Stage Step
- Blue Ocean
- HTML Publisher plugin

#### 🔑 Jenkins Credentials:
DockerHub credentials → ID: dockerhub

### 🧮 3. Jenkins Pipeline

#### Your Jenkinsfile (stored in the GitHub repo) automates:

- Clone repository
- Run flake8 for linting
- Scan code with Trivy
- Build Docker image
- Scan Docker image with Trivy
- Login to Docker Hub
- Push image
- Cleanup temporary containers/images


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

- Opened the Jenkins Script Console (Manage Jenkins → Script Console).

- Executed the following command to disable the restrictive CSP policy:
```bash
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")
```
This allowed Jenkins to render inline HTML safely and display all reports in the browser directly from the build artifacts.


---

## ☸️ 3. CD Setup – Minikube + ArgoCD (VM2)
### 🧰 1. Install Minikube
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

### 🚀 3.  Install kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 🎯 4. Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
### 5. Port-Forward ArgoCD:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 6. Access ArgoCD UI:
http://(VM2-IP):8080

### 7. ArgoCD Login:
- Username: admin
- Password: type this command in the terminal 

`kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d`

### 🧱 8. Helm Chart Deployment

Your Helm chart (stored in GitHub) defines:
- Deployment
- Service (type: NodePort)
- Configurations

### 🔗 9. Connect ArgoCD App

In ArgoCD UI → “New App” →

- Repository URL: `https://github.com/Philiprime97/myapp-helm.git`
- Path: `.`
- Cluster: `https://kubernetes.default.svc`
- Namespace: `aws`
- Then click Sync → ArgoCD will deploy automatically.

### 🌐 10. Access the Application

Since Minikube runs locally:
```bash
minikube tunnel
kubectl port-forward svc/aws 5000:5001 -n aws --address=0.0.0.0
```

Now access the app from your browser:
👉 http://localhost:8080

---

## 🏁 Conclusion

This project showcases a complete CI/CD workflow integrating:

- Source control with GitHub
- Continuous Integration with Jenkins
- Containerization with Docker
- Security Scanning with Trivy
- Continuous Delivery with ArgoCD & Helm
- Kubernetes orchestration on Minikube

