pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-northeast-2'
        AWS_ACCOUNT_ID = '471112853004'
        ECR_REPOSITORY = 'test'
    }

    stages {
        stage('Build and Push Images') {
            steps {
                script {
                    // Docker 이미지 빌드 및 푸시를 위한 함수 정의
                    def buildAndPushImage = { imageName ->
                        def version = readFile(file: "Dockerfile/${imageName}/VERSION").trim()
                        def dockerImageTag = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${imageName}-${version}"
                        def customImage = docker.build("${imageName}:${version}", "-f Dockerfile/${imageName}/Dockerfile .")
                        sh "docker tag ${imageName}:${version} ${dockerImageTag}"
                        sh "docker push ${dockerImageTag}"
                    }

                    // AWS Credentials로 Docker에 로그인
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: '4bdcbad7-61ab-479b-ba29-3b8d6ccfbb89', // AWS Credentials Plugin에서 설정한 credentialsId 입력
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        // AWS ECR에 로그인
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

                        // 각 이미지를 빌드하고 푸시
                        ['web-intro', 'web-home'].each { imageName ->
                            def currentVersion = readFile(file: "Dockerfile/${imageName}/VERSION").trim()
                            def latestVersion = sh(script: "aws ecr describe-images --repository-name ${ECR_REPOSITORY} --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' --output text || echo ''", returnStdout: true).trim()
                            
                            if (currentVersion != latestVersion) {
                                buildAndPushImage(imageName)
                            } else {
                                echo "Version ${currentVersion} of image ${imageName} is already up to date. Skipping build and push."
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "빌드 및 ECR 푸시 성공"
        }
        failure {
            echo '빌드 또는 ECR 푸시 실패'
        }
    }
}
