pipeline {
    agent any

    environment {
        // AWS 계정 ID와 리전을 설정합니다.
        AWS_DEFAULT_REGION = 'ap-northeast-2'
        AWS_ACCOUNT_ID = '471112853004'

        // ECR 리포지토리 이름과 Docker 이미지 태그를 설정합니다.
        ECR_REPOSITORY = 'test'
        IMAGE_TAG = 'latest'

        // Docker 이미지 이름과 버전을 설정합니다.
        DOCKERFILE_PATH = 'Dockerfile' // Dockerfile이 있는 경로 설정
        DOCKER_IMAGE_NAME = 'test'
    }

    stages {
        stage('Build') {
            steps {
                // GitHub에서 Dockerfile을 빌드합니다.
                script {
                    def customImage = docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}", "-f ${DOCKERFILE_PATH} .")

                    // AWS ECR에 로그인합니다.
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'your-aws-credentials-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    }

                    // Docker 이미지를 AWS ECR에 푸시합니다.
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
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
