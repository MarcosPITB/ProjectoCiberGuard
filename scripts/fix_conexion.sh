#!/bin/bash
# scripts/fix_conexion.sh

TARGET_FILE="/var/www/html/conexion.php"
CACHE_ENDPOINT="/tmp/db_endpoint.txt"
PATCH_FILE="/tmp/patch_permisos.php"

echo "=== Iniciando script de ajuste post-despliegue ==="

if [ -f "$CACHE_ENDPOINT" ]; then
    REAL_ENDPOINT=$(cat "$CACHE_ENDPOINT")
    echo "Endpoint de AWS RDS detectado: $REAL_ENDPOINT"
    
    if [ -f "$TARGET_FILE" ]; then
        
        # 1. EJECUTAR EL PARCHE DE PERMISOS COMO SUPERUSUARIO (postgres)
        # Esto soluciona de raíz el problema del ID autoincremental del formulario de registro
        cat << EOFIX > "$PATCH_FILE"
<?php
\$host = "$REAL_ENDPOINT";
\$port = "5432";
\$dbname = "ciberguard";
\$user = "postgres"; 
\$password = "TuPasswordSeguro123"; 

\$conn = pg_connect("host=\$host port=\$port dbname=\$dbname user=\$user password=\$password sslmode=require");

if (\$conn) {
    \$query = "GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO cyberuser;";
    pg_query(\$conn, \$query);
    echo "--- Permisos de secuencias inyectados con éxito desde PHP maestro ---\n";
} else {
    echo "--- ERROR: El parche temporal no pudo autenticarse como postgres ---\n";
}
?>
EOFIX

        # Forzamos la ejecución del parche usando el motor de PHP interno de la EC2
        php "$PATCH_FILE"
        rm -f "$PATCH_FILE" # Lo eliminamos por seguridad informática para no dejar credenciales maestras

        # 2. ESCRIBIR EL ARCHIVO CONEXION.PHP DEFINITIVO
        # El archivo queda configurado con el usuario limitado (cyberuser) como dicta la seguridad
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
        echo "Archivo conexion.php definitivo generado con éxito."
    else
        echo "ERROR: El archivo conexion.php no fue encontrado por CodeDeploy."
    fi
else
    echo "ADVERTENCIA: No se encontró el archivo temporal /tmp/db_endpoint.txt."
fi

# Ajustar los permisos correspondientes de Nginx
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html
echo "=== Proceso post-despliegue finalizado con éxito ==="
