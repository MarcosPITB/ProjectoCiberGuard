#!/bin/bash
chown -R www-data:www-data /var/www/html
systemctl restart php8.1-fpm nginx
