pipeline {
    agent any
    
    environment {
        // Vincula las variables a las credenciales internas de Jenkins
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_SESSION_TOKEN     = credentials('aws-session-token')
        AWS_DEFAULT_REGION    = "us-east-1"
    }

    stages {
        stage('Preparar Paquete') {
            steps {
                sh "zip -r deploy.zip web/ scripts/ appspec.yml"
            }
        }
        stage('Cargar a AWS') {
            steps {
                sh "aws s3 cp deploy.zip s3://ciberguard-artifacts-8a0ba4c0/deploy.zip"
            }
        }
        stage('Desplegar con CodeDeploy') {
            steps {
                sh """
                aws deploy create-deployment \
                    --application-name CiberGuard-App \
                    --deployment-group-name web-servers-dg \
                    --s3-location bucket=ciberguard-artifacts-8a0ba4c0,key=deploy.zip,bundleType=zip
                """
            }
        }
    }
}
