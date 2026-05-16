#!/bin/bash
# scripts/fix_conexion.sh

TARGET_FILE="/var/www/html/conexion.php"
CACHE_ENDPOINT="/tmp/db_endpoint.txt"

echo "=== Iniciando script de ajuste post-despliegue ==="

# 1. Comprobar si existe el endpoint real cacheado por Terraform
if [ -f "$CACHE_ENDPOINT" ]; then
    REAL_ENDPOINT=$(cat "$CACHE_ENDPOINT")
    echo "Endpoint de AWS RDS detectado: $REAL_ENDPOINT"
    
    # Reemplazar la línea de localhost por la del endpoint real en el archivo final
    if [ -f "$TARGET_FILE" ]; then
        sed -i "s/\$host = \"localhost\";/\$host = \"$REAL_ENDPOINT\";/g" "$TARGET_FILE"
        echo "Sustitución en conexion.php completada con éxito."
    else
        echo "ERROR: El archivo conexion.php no fue encontrado por CodeDeploy."
    fi
else
    echo "ADVERTENCIA: No se encontró el archivo temporal /tmp/db_endpoint.txt."
fi

# 2. Asegurar permisos correctos para Nginx
echo "Corrigiendo permisos de la carpeta web compartida..."
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

echo "=== Proceso post-despliegue finalizado con éxito ==="
