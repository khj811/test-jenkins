pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-northeast-2'
        AWS_ACCOUNT_ID = '471112853004'
        ECR_REPOSITORY = 'web-intro'
        IMAGE_TAG = "${BUILD_NUMBER}" // 이미지 태그를 젠킨스 빌드 번호로 설정
        DOCKERFILE_PATH = 'Dockerfile'
        DOCKER_IMAGE_NAME = 'web-intro'
        HELM_CHART_PATH = 'web-helm' // 헬름 차트가 있는 디렉토리 경로
        HELM_RELEASE_NAME = 'web-app' // 배포할 헬름 릴리스 이름
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Docker 이미지 빌드 with --no-cache=true
                    def customImage = docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}", "--no-cache=true -f ${DOCKERFILE_PATH} .")

                    // AWS ECR에 로그인 및 이미지 푸시
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: '4bdcbad7-61ab-479b-ba29-3b8d6ccfbb89', // AWS Credentials Plugin에서 설정한 credentialsId 입력
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
                        sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Helm Chart Values') {
            steps {
                script {
                    // 헬름 차트 값 업데이트
                    sh "sed -i 's|imageTag:.*|imageTag: ${IMAGE_TAG}|' ${HELM_CHART_PATH}/values.yaml"
                }
            }
        }

        stage('Deploy Helm Chart with Argo CD') {
            steps {
                script {
                    // 헬름 차트 배포
                    sh "helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH}"
                    sh "argocd app sync ${HELM_RELEASE_NAME} --self-heal"
                }
            }
        }
    }

    post {
        success {
            echo "빌드 및 ECR 푸시 성공, 이미지 버전: ${IMAGE_TAG}"
        }
        failure {
            echo '빌드, ECR 푸시, 또는 Helm 배포 실패'
        }
    }
}
