pipeline {
    agent {
        label 'build-agent'
    }

	environment {
		DOCKER_HUB_USER = 'rshvets89'
		IMAGE_NAME      = 'books-front-service'
		IMAGE_TAG       = "${env.BUILD_NUMBER}"
	}

	stages {
		stage('Checkout') {
			steps {
				echo 'Checking out ...'
				checkout scm
				echo 'Checked out'
			}
		}

		stage('Build') {
			steps {
				echo 'Building ...'

				script {
					sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."

					sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
					sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
				}

				echo 'Built'
			}
		}

		stage('Deploy') {
			steps {
				echo 'Deploying ...'

				withCredentials([
						usernamePassword(
							credentialsId: 'dockerhub-credentials',
							usernameVariable: 'DOCKER_USER',
							passwordVariable: 'DOCKER_PASS'
						)]) {

					script {
						sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"

						sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
						sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
					}
				}

				echo 'Deployed'
			}
		}
	}

	post {
        always {
            sh 'docker logout'
        }
    }
}