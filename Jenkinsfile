pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_SESSION_TOKEN     = credentials('aws-session-token')
        AWS_DEFAULT_REGION    = "us-east-1"
    }

    stages {
        stage('Limpiar Espacio') {
            steps {
                sh "rm -f deploy.zip"
            }
        }

        stage('Preparar Paquete') {
            steps {
                // Empaquetado estricto incluyendo los componentes y hooks de CodeDeploy
                sh "zip -r deploy.zip web/ scripts/ appspec.yml"
            }
        }
        
        stage('Cargar a AWS S3') {
            steps {
                sh "aws s3 cp deploy.zip s3://ciberguard-artifacts-04e93b3d/deploy.zip"
            }
        }
        
        stage('Desplegar con CodeDeploy') {
            steps {
                sh """
                aws deploy create-deployment \
                    --application-name CiberGuard-App \
                    --deployment-group-name web-servers-dg \
                    --ignore-application-stop-failures \
                    --file-exists-behavior OVERWRITE \
                    --s3-location bucket=ciberguard-artifacts-04e93b3d,key=deploy.zip,bundleType=zip
                """
            }
        }
    }
}
