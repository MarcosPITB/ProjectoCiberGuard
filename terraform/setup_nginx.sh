#!/bin/bash
# 1. Actualizar el sistema e instalar dependencias requeridas
apt-get update -y
apt-get install -y nginx php-fpm php-pgsql awscli nfs-common ruby-full wget git

# 2. Instalar, arrancar y habilitar el Agente de CodeDeploy
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent

# 3. Crear el directorio raíz y montar el almacenamiento EFS compartido
mkdir -p /var/www/html
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}.efs.us-east-1.amazonaws.com:/ /var/www/html

# Asignar la propiedad al usuario de Nginx y CodeDeploy
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

# 4. Configurar el servidor Nginx con soporte SSL Auto-firmado
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=ES/ST=BCN/L=BCN/O=CiberGuard/CN=ciberguard.interno"

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

# Reiniciar servicios web base
systemctl restart nginx
systemctl restart php8.1-fpm

# 5. GUARDADO SEGURO: Almacenar el endpoint real en memoria temporal del sistema
# Esto evita que CodeDeploy lo pise más tarde.
echo "${db_endpoint}" > /tmp/db_endpoint.txt
chmod 644 /tmp/db_endpoint.txt
