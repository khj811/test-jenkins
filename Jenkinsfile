pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-northeast-2'
        AWS_ACCOUNT_ID = '471112853004'
        ECR_REPOSITORY = 'test'
        IMAGE_TAG = 'latest'
        DOCKER_IMAGE = 'docker:19.03.12'
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image DOCKER_IMAGE
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    def customImage = docker.build("your-docker-image-name:${IMAGE_TAG}")

                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'your-aws-credentials-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    }

                    sh "docker tag your-docker-image-name:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo '빌드 및 ECR 푸시 성공'
        }
        failure {
            echo '빌드 또는 ECR 푸시 실패'
        }
    }
}
