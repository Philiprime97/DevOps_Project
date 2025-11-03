🧾 README.md — DevOps Final Project
📘 Project Overview

This project demonstrates a complete CI/CD pipeline for a Python-based application that fetches resource data from an AWS account.
It integrates GitHub, Jenkins, Docker, Trivy, Helm, ArgoCD, and Minikube to automate build, test, security scanning, deployment, and delivery processes.

🧩 Project Architecture

Components used:

Component	Purpose
Local PC (Windows)	Development machine, source code editing, and GitHub pushes
VM1 (Jenkins Server)	CI pipeline: code linting, image building, scanning, and pushing to Docker Hub
VM2 (Minikube + ArgoCD)	CD environment: deploys Helm chart of the app to Kubernetes cluster

⚙️ 1. Application Setup
🐍 Python Application

The app fetches AWS resource data using Boto3.

🧱 Local Setup
# Create virtual environment
python -m venv venv
source venv/bin/activate  # (On Windows: venv\Scripts\activate)

# Install dependencies
pip install -r requirements.txt

# Push to GitHub
git init
git remote add origin https://github.com/<your-username>/<repo-name>.git
git add .
git commit -m "Initial commit"
git push origin main


⚙️ 2. CI Setup – Jenkins Server (VM1)
🧰 Install Jenkins
sudo apt update
sudo apt install openjdk-11-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins


Access Jenkins:
👉 http://<vm1-ip>:8080

🧩 Jenkins Plugins:
Pipeline: Stage Step
Blue Ocean
HTML Publisher plugin


🔑 Jenkins Credentials:
DockerHub credentials → ID: dockerhub


🧮 3. Jenkins Pipeline

Your Jenkinsfile (stored in the GitHub repo) automates:

Clone repository
Run flake8 linting
Scan code with Trivy
Build Docker image
Scan Docker image with Trivy
Login to Docker Hub
Push image
Cleanup temporary containers/images


☸️ 4. CD Setup – Minikube + ArgoCD (VM2)
🧰 Install Minikube
sudo apt update -y
sudo apt install -y curl apt-transport-https virtualbox virtualbox-ext-pack
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --driver=docker

🚀 Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

🎯 Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


Access ArgoCD UI:

kubectl port-forward svc/argocd-server -n argocd 8080:443


Then open:
👉 https://localhost:8080

🪶 ArgoCD Login
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d



🧱 5. Helm Chart Deployment

Your Helm chart (stored in GitHub) defines:
Deployment
Service (type: NodePort)
Configurations

🔗 Connect ArgoCD App

In ArgoCD UI → “New App” →

Repository URL: https://github.com/Philiprime97/myapp-helm.git
Path: .
Cluster: https://kubernetes.default.svc
Namespace: default
Then click Sync → ArgoCD will deploy automatically.


🌐 6. Access the Application

Since Minikube runs locally:

minikube tunnel
kubectl port-forward svc/myapp-service 8080:80

Now access the app from your browser:
👉 http://localhost:8080


🏁 Conclusion

This project showcases a complete CI/CD workflow integrating:

Source control with GitHub
Continuous Integration with Jenkins
Containerization with Docker
Security Scanning with Trivy
Continuous Delivery with ArgoCD & Helm
Kubernetes orchestration on Minikube
