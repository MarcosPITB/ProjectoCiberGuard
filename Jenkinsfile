pipeline {
    agent any
    
    environment {
        // Vinculación segura de credenciales globales almacenadas en el entorno de Jenkins
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_SESSION_TOKEN     = credentials('aws-session-token')
        AWS_DEFAULT_REGION    = "us-east-1"
    }

    stages {
        stage('Limpiar Espacio') {
            steps {
                // Previene arrastrar artefactos residuales de compilaciones previas
                sh "rm -f deploy.zip"
            }
        }

        stage('Preparar Paquete') {
            steps {
                // Comprime estrictamente los componentes necesarios para la aplicación web
                sh "zip -r deploy.zip web/ scripts/ appspec.yml"
            }
        }
        
        stage('Cargar a AWS S3') {
            steps {
                // Sube el paquete empaquetado al bucket S3 de artefactos
                sh "aws s3 cp deploy.zip s3://ciberguard-artifacts-041ace8b/deploy.zip"
            }
        }
        
        stage('Desplegar con CodeDeploy') {
            steps {
                // Invoca la orden de despliegue directo hacia el grupo de Auto Scaling
                // --ignore-application-stop-failures: Omite ganchos de parada corruptos del pasado
                // --file-exists-behavior OVERWRITE: Permite a las máquinas escribir coordinadamente en EFS
                sh """
                aws deploy create-deployment \
                    --application-name CiberGuard-App \
                    --deployment-group-name web-servers-dg \
                    --ignore-application-stop-failures \
                    --file-exists-behavior OVERWRITE \
                    --s3-location bucket=ciberguard-artifacts-041ace8b,key=deploy.zip,bundleType=zip
                """
            }
        }
    }
}
