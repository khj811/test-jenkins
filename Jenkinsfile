pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-northeast-2'
        AWS_ACCOUNT_ID = '471112853004'
        ECR_REPOSITORY = 'web-intro'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKERFILE_PATH = 'Dockerfile'
        DOCKER_IMAGE_NAME = 'web-intro'
        HELM_CHART_PATH = 'web-helm' // 헬름 차트가 있는 디렉토리 경로
        GIT_BRANCH = 'main' // GitHub의 기본 브랜치 이름을 명시적으로 설정
        GITHUB_TOKEN = credentials('github-token') // GitHub 개인 액세스 토큰 ID
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Docker 이미지 빌드 with --no-cache=true
                    def customImage = docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}", "--no-cache=true -f ${DOCKERFILE_PATH} .")

                    // AWS Credentials로 Docker에 로그인
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: '4bdcbad7-61ab-479b-ba29-3b8d6ccfbb89', // AWS Credentials Plugin에서 설정한 credentialsId 입력
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        // AWS ECR에 로그인 및 이미지 푸시
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
                        sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "빌드 및 ECR 푸시 성공, 이미지 버전: ${IMAGE_TAG}"

            // 이미지 빌드 및 푸시가 성공했을 때, Helm Chart의 값을 업데이트하고 Git 저장소에 푸시
            script {
                // 헬름 차트 값 업데이트
                sh "sed -i 's|imageTag:.*|imageTag: ${IMAGE_TAG}|' ${HELM_CHART_PATH}/values.yaml"
                
                // Git에 변경 사항을 커밋하고 푸시
                sh "git config --global user.email 'hajinkim811@gmail.com'"
                sh "git config --global user.name 'khj811'"
                sh "git checkout -f ${GIT_BRANCH}" // main 브랜치로 강제로 체크아웃
                sh "git add ${HELM_CHART_PATH}/values.yaml"
                sh "git commit -m 'Update imageTag in Helm Chart to ${IMAGE_TAG}'"
                sh "git push origin ${GIT_BRANCH}" // ${GIT_BRANCH}에 정의된 브랜치로 푸시
            }
        }
        failure {
            echo '빌드 또는 ECR 푸시 실패'
        }
    }
}
