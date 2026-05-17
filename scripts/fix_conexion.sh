cd ~/Downloads/projectoCyberGuard

cat << 'EOF' > scripts/fix_conexion.sh
#!/bin/bash
# scripts/fix_conexion.sh

TARGET_FILE="/var/www/html/conexion.php"
CACHE_ENDPOINT="/tmp/db_endpoint.txt"

echo "=== Iniciando script de ajuste post-despliegue ==="

if [ -f "$CACHE_ENDPOINT" ]; then
    REAL_ENDPOINT=$(cat "$CACHE_ENDPOINT")
    echo "Endpoint de AWS RDS detectado: $REAL_ENDPOINT"
    
    if [ -f "$TARGET_FILE" ]; then
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
    else
        echo "ERROR: El archivo conexion.php no fue encontrado por CodeDeploy."
    fi
else
    echo "ADVERTENCIA: No se encontró el archivo temporal /tmp/db_endpoint.txt."
fi

chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html
echo "=== Proceso post-despliegue finalizado con éxito ==="
EOF

chmod +x scripts/fix_conexion.sh
