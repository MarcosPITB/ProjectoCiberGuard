<?php
session_start();
if (!isset($_SESSION['usuario'])) { header("Location: login.php"); exit(); }
include("conexion.php");

$mensaje = "";
$tipo = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Sincronizado con los 'name' del formulario de abajo
    $tipo_incidente = $_POST['tipo'];
    $criticidad = $_POST['criticidad'];
    $descripcion = $_POST['descripcion'];

    // Recuperamos el ID del usuario de la sesión para la Llave Foránea
    $res = pg_query_params($conn, "SELECT id FROM usuarios WHERE nombre_usuario = $1", array($_SESSION['usuario']));
    $user = pg_fetch_assoc($res);
    $usuario_id = $user['id'];

    $sql = "INSERT INTO incidentes (usuario_id, tipo_incidente, criticidad, descripcion, tecnico_responsable)
            VALUES ($1, $2, $3, $4, $5)";

    $result = pg_query_params($conn, $sql, array($usuario_id, $tipo_incidente, $criticidad, $descripcion, $_SESSION['usuario']));

    if ($result) {
        $mensaje = "Incidente reportado con éxito.";
        $tipo = "success";
    } else {
        $mensaje = "Error al reportar el incidente.";
        $tipo = "error";
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Nueva Incidencia | CyberGuard</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="form-wrapper">
        <div class="glass-card form-card">
            <h2>Nueva Incidencia</h2>
            
            <?php if($mensaje): ?>
                <div class="alert <?php echo ($tipo == 'success') ? 'alert-success' : 'alert-error'; ?>">
                    <?php echo $mensaje; ?>
                </div>
            <?php endif; ?>

            <form method="POST">
                <div class="form-group">
                    <label>Tipo de Incidente</label>
                    <select name="tipo" class="form-control">
                        <option value="Phishing">Phishing</option>
                        <option value="Malware">Malware</option>
                        <option value="Acceso no autorizado">Acceso no autorizado</option>
                        <option value="Otros">Otros</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Criticidad</label>
                    <select name="criticidad" class="form-control">
                        <option value="Baja">Baja</option>
                        <option value="Media">Media</option>
                        <option value="Alta">Alta</option>
                        <option value="Crítica">Crítica</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Descripción</label>
                    <textarea name="descripcion" class="form-control" rows="4" required></textarea>
                </div>
                <button type="submit" class="btn btn-primary" style="width:100%;">Enviar Reporte</button>
            </form>
            <div class="form-footer">
                <a href="panel.php" style="color: #00d2ff;">Volver al Panel</a>
            </div>
        </div>
    </div>
</body>
</html>
