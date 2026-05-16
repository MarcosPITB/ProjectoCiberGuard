pipeline {
    agent any
    
    environment {
        // Vincula de forma segura las variables de entorno con tus credenciales de Jenkins
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_SESSION_TOKEN     = credentials('aws-session-token')
        AWS_DEFAULT_REGION    = "us-east-1"
    }

    stages {
        stage('Limpiar Espacio') {
            steps {
                // Elimina paquetes de despliegues anteriores en el espacio de trabajo de Jenkins
                sh "rm -f deploy.zip"
            }
        }

        stage('Preparar Paquete') {
            steps {
                // Empaqueta únicamente lo necesario para el servidor web (11 KB)
                sh "zip -r deploy.zip web/ scripts/ appspec.yml"
            }
        }
        
        stage('Cargar a AWS S3') {
            steps {
                // Sube el artefacto empaquetado a tu bucket de almacenamiento de AWS
                sh "aws s3 cp deploy.zip s3://ciberguard-artifacts-8a0ba4c0/deploy.zip"
            }
        }
        
        stage('Desplegar con CodeDeploy') {
            steps {
                // Ordena a CodeDeploy iniciar el despliegue utilizando el nuevo archivo zip.
                // --ignore-application-stop-failures: Salta bloqueos fantasmas del pasado.
                // --file-exists-behavior OVERWRITE: Solución crítica para evitar colisiones en el EFS compartido.
                sh """
                aws deploy create-deployment \
                    --application-name CiberGuard-App \
                    --deployment-group-name web-servers-dg \
                    --ignore-application-stop-failures \
                    --file-exists-behavior OVERWRITE \
                    --s3-location bucket=ciberguard-artifacts-8a0ba4c0,key=deploy.zip,bundleType=zip
                """
            }
        }
    }
}
