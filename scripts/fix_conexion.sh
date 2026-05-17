#!/bin/bash
# scripts/fix_conexion.sh

TARGET_FILE="/var/www/html/conexion.php"
CACHE_ENDPOINT="/tmp/db_endpoint.txt"

echo "=== Iniciando script de ajuste post-despliegue ==="

if [ -f "$CACHE_ENDPOINT" ]; then
    REAL_ENDPOINT=$(cat "$CACHE_ENDPOINT")
    echo "Endpoint de AWS RDS detectado: $REAL_ENDPOINT"
    
    if [ -f "$TARGET_FILE" ]; then
        # Escribimos el conexion.php limpio y añadimos la query mágica dentro del propio PHP
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

// SOLUCIÓN EN CALIENTE: Ejecutar el GRANT directamente desde PHP para evitar instalar psql
\$query_permisos = "GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO cyberuser;";
@pg_query(\$conn, \$query_permisos);
?>
EOPHP
        echo "Archivo conexion.php regenerado post-despliegue con éxito."
    else
        echo "ERROR: El archivo conexion.php no fue encontrado por CodeDeploy."
    fi
else
    echo "ADVERTENCIA: No se encontró el archivo temporal /tmp/db_endpoint.txt."
fi

# Corregir permisos de Nginx de forma segura
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html
echo "=== Proceso post-despliegue finalizado con éxito ==="
