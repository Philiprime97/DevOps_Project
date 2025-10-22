pipeline {
    agent any

    environment {
        HARBOR_URL = '192.168.1.179:80'
        HARBOR_PROJECT = 'devops'
        IMAGE_NAME = 'myapp-a'
        IMAGE_TAG = '1'
    }

    stages {

        stage('Docker Info Check') {
            steps {
                sh 'docker info'
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    cd docker &&
                    docker build -t ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Login to Harbor') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'devops-test', usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                    sh 'echo $HARBOR_PASS | docker login 192.168.1.179:80 -u $HARBOR_USER --password-stdin'
                }
            }
        }

        stage('Push Image to Harbor') {
            steps {
                script {
                    sh """
                    docker push ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up local images..."
            sh "docker rmi ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG} || true"
        }
        success {
            echo "✅ Image pushed successfully to Harbor: ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Build failed. Check logs above."
        }
    }
}
