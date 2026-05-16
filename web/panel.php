<?php
session_start();
if (!isset($_SESSION['usuario'])) {
    header("Location: login.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>CyberGuard - Panel</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="form-wrapper" style="max-width: 600px;">
        <div class="glass-card" style="text-align: center;">
            <h1>Bienvenido, <span style="color: #00d2ff;"><?php echo htmlspecialchars($_SESSION['usuario']); ?></span></h1>
            <p>Has accedido al sistema de gestión de seguridad.</p>

            <div style="background: rgba(255,255,255,0.05); padding: 20px; border-radius: 10px; margin: 20px 0;">
                <h3>Gestión de Incidencias</h3>
                <p>Documenta un nuevo hallazgo técnico o brecha de seguridad.</p>
                <br>
                <a href="registro_incidente.php" class="btn btn-primary" style="text-decoration: none;">Abrir Formulario</a>
            </div>

            <br>
            <a href="logout.php" style="color: #ff4b2b; text-decoration: none;">Cerrar Sesión</a>
        </div>
    </div>
</body>
</html>
