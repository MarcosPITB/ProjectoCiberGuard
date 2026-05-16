#!/bin/bash
apt-get update -y
apt-get install -y nginx php-fpm php-pgsql awscli nfs-common ruby-full wget git

# Montaje EFS
mkdir -p /var/www/html
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}.efs.us-east-1.amazonaws.com:/ /var/www/html

# Agente CodeDeploy
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Configuración Nginx SSL
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=ES/ST=BCN/L=BCN/O=CiberGuard/CN=ciberguard.interno"

cat <<'EOT' > /etc/nginx/sites-available/default
server {
    listen 443 ssl default_server;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    root /var/www/html;
    index index.php index.html;
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
EOT
systemctl restart nginx
