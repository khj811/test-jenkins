pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-northeast-2'
        AWS_ACCOUNT_ID = '471112853004'
        ECR_REPOSITORY = 'web-intro'
        IMAGE_TAG = '27'
        DOCKERFILE_PATH = 'Dockerfile'
        DOCKER_IMAGE_NAME = 'web-intro'
        GITHUB_CREDENTIALS_ID = 'github-token' // Jenkins에 설정한 GitHub credentials ID
        GIT_REPO_URL = 'https://github.com/khj811/test-jenkins.git'
        GIT_BRANCH = 'main'
        HELM_VALUES_PATH = 'web-helm/values.yaml' // Helm 차트의 values.yaml 파일 경로 (루트 디렉토리 기준)
    }

    stages {
        stage('Build') {
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

        stage('Update Helm Values') {
            steps {
                script {
                    // GitHub 리포지토리 클론 및 Helm values.yaml 파일 업데이트
                    withCredentials([usernamePassword(credentialsId: "${GITHUB_CREDENTIALS_ID}", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        dir('test-jenkins') {
                            sh """
                            git checkout ${GIT_BRANCH}
                            sed -i 's|imageTag:.*|imageTag: ${IMAGE_TAG}|' ${HELM_VALUES_PATH}
                            git config user.email "jenkins@example.com"
                            git config user.name "Jenkins"
                            git add ${HELM_VALUES_PATH}
                            git commit -m "Update image tag to ${IMAGE_TAG}"
                            git pull origin ${GIT_BRANCH} --rebase
                            git push origin ${GIT_BRANCH} --force
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "빌드 및 ECR 푸시 성공, 이미지 버전: ${IMAGE_TAG}"
        }
        failure {
            echo '빌드 또는 ECR 푸시 실패'
        }
    }
}
