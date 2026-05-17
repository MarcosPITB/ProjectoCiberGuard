cd ~/Downloads/projectoCyberGuard

cat << 'EOF' > scripts/fix_conexion.sh
#!/bin/bash
# scripts/fix_conexion.sh

TARGET_FILE="/var/www/html/conexion.php"
CACHE_ENDPOINT="/tmp/db_endpoint.txt"

echo "=== Iniciando script de ajuste post-despliegue ==="

# 1. Comprobar si existe el endpoint real cacheado por Terraform
if [ -f "$CACHE_ENDPOINT" ]; then
    REAL_ENDPOINT=$(cat "$CACHE_ENDPOINT")
    echo "Endpoint de AWS RDS detectado: $REAL_ENDPOINT"
    
    if [ -f "$TARGET_FILE" ]; then
        # Escribir la configuración limpia en conexion.php
        cat << EOPHP > "$TARGET_FILE"
<?php
\$host = "$REAL_ENDPOINT";
\$port = "5432";
\$dbname = "ciberguard";
\$user = "cyberuser";
\$password = "CiberGuard2026!";

\$conn = pg_connect("host=\$host port=\$port dbname=\$dbname user=\$user password=\$password sslmode=require");

if (!\$conn) {
    die("Error de conexión a la base de datos.");
}
?>
EOPHP
        echo "Archivo conexion.php regenerado post-despliegue con éxito."
        
        # 2. INSTALACIÓN Y CORRECCIÓN DE PERMISOS EN CALIENTE (Tu Fix definitivo)
        echo "Asegurando herramientas de PostgreSQL e inyectando permisos de secuencias..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get update && apt-get install -y postgresql-client
        
        PGPASSWORD="CiberGuard2026!" psql -h "$REAL_ENDPOINT" -U cyberuser -d ciberguard -c "GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO cyberuser;"
        echo "Permisos de secuencias aplicados correctamente."
        
    else
        echo "ERROR: El archivo conexion.php no fue encontrado por CodeDeploy."
    fi
else
    echo "ADVERTENCIA: No se encontró el archivo temporal /tmp/db_endpoint.txt."
fi

# 3. Corregir permisos finales para el servidor web Nginx
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html
echo "=== Proceso post-despliegue finalizado con éxito ==="
EOF

# Mantener permisos de ejecución locales
chmod +x scripts/fix_conexion.sh
