#!/bin/bash
# 1. Actualizar e instalar dependencias básicas
apt-get update -y
apt-get install -y nginx php-fpm php-pgsql awscli nfs-common ruby-full wget git

# 2. Instalar y Asegurar el Agente de CodeDeploy PRIMERO
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

# FORZAR el arranque y activación del agente para que responda a AWS
systemctl enable codedeploy-agent
systemctl start codedeploy-agent

# 3. Preparar el directorio Web y Montar EFS con permisos correctos
mkdir -p /var/www/html
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}.efs.us-east-1.amazonaws.com:/ /var/www/html

# Asegurar que tanto Nginx como CodeDeploy tengan permisos de escribir en el almacenamiento
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

# 4. Configuración de Nginx con SSL
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=ES/ST=BCN/L=BCN/O=CiberGuard/CN=ciberguard.interno"

cat <<'EOT' > /etc/nginx/sites-available/default
server {
    listen 443 ssl default_server;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
EOT

# 5. Reiniciar servicios para aplicar la configuración
systemctl restart nginx
systemctl restart php8.1-fpm
