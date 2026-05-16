<?php
// Este archivo se genera dinámicamente en el servidor AWS por setup_nginx.sh
// Si lo pruebas localmente, ajusta los valores.
$host = "localhost"; 
$port = "5432";
$dbname = "cyberguard";
$user = "cyberuser";
$password = "CiberGuard2026!";

$conn = pg_connect("host=$host port=$port dbname=$dbname user=$user password=$password");

if (!$conn) {
    die("Error de conexión a la base de datos.");
}
?>