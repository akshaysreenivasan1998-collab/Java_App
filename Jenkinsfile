pipeline {
    agent any

    environment {
        DOCKER_IMAGE    = "akshays1998/helloworld"
        DOCKER_TAG      = "${env.BUILD_NUMBER}"

        // Minikube Server Details
        MINIKUBE_SERVER = "YOUR_MINIKUBE_PUBLIC_IP"
        MINIKUBE_USER   = "ec2-user"
    }

    stages {

        stage('Build Maven Artifact') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'Dockertocken',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh """
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin

                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {

                sshagent(['jenkin']) {

                    sh """

                    # Create manifest directory on Minikube server
                    ssh -o StrictHostKeyChecking=no \
                    ${MINIKUBE_USER}@${MINIKUBE_SERVER} \
                    'mkdir -p /home/${MINIKUBE_USER}/manifest'

                    # Copy Kubernetes manifests
                    scp -o StrictHostKeyChecking=no \
                    manifest/*.yml \
                    ${MINIKUBE_USER}@${MINIKUBE_SERVER}:/home/${MINIKUBE_USER}/manifest/

                    # Deploy application
                    ssh -o StrictHostKeyChecking=no \
                    ${MINIKUBE_USER}@${MINIKUBE_SERVER} '

                        cd /home/${MINIKUBE_USER}/manifest

                        # Replace image dynamically
                        sed -i "s|image: .*|image: ${DOCKER_IMAGE}:${DOCKER_TAG}|g" deployment.yml

                        # Apply manifests
                        kubectl apply -f .

                        # Restart deployment
                        kubectl rollout restart deployment springboot-app

                        # Verify deployment
                        kubectl get pods
                        kubectl get svc
                    '
                    """
                }
            }
        }
    }

    post {

        always {

            sh 'docker logout'

            cleanWs()
        }

        success {
            echo 'Application Successfully Deployed to Minikube'
        }

        failure {
            echo 'Pipeline Failed'
        }
    }
}
