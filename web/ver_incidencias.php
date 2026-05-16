<?php
session_start();
if (!isset($_SESSION['usuario'])) { header("Location: login.php"); exit(); }
include("conexion.php");

// 1. Obtenemos el ID del usuario logueado
$res_user = pg_query_params($conn, "SELECT id FROM usuarios WHERE nombre_usuario = $1", array($_SESSION['usuario']));
$user_data = pg_fetch_assoc($res_user);
$usuario_id = $user_data['id'];

// 2. Consultamos solo sus incidencias
$query = "SELECT * FROM incidentes WHERE usuario_id = $1 ORDER BY fecha_reporte DESC";
$result = pg_query_params($conn, $query, array($usuario_id));
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Incidencias | CyberGuard</title>
    <link rel="stylesheet" href="style.css">
    <style>
        /* Estilos extra para la tabla dentro del glass-card */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; color: white; }
        th, td { padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.1); text-align: left; }
        th { background: rgba(255,255,255,0.1); color: #00d2ff; }
        .crit-Alta { color: #ff4b2b; font-weight: bold; }
        .crit-Media { color: #ffa500; }
        .crit-Baja { color: #00ff00; }
    </style>
</head>
<body>
    <div class="form-wrapper" style="max-width: 900px;">
        <div class="glass-card">
            <h2>Mis Incidencias Reportadas</h2>
            <p>Listado de brechas y hallazgos técnicos registrados por <strong><?php echo $_SESSION['usuario']; ?></strong>.</p>

            <table>
                <thead>
                    <tr>
                        <th>Tipo</th>
                        <th>Criticidad</th>
                        <th>Descripción</th>
                        <th>Fecha</th>
                    </tr>
                </thead>
                <tbody>
                    <?php while ($row = pg_fetch_assoc($result)): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($row['tipo_incidente']); ?></td>
                            <td class="crit-<?php echo $row['criticidad']; ?>">
                                <?php echo htmlspecialchars($row['criticidad']); ?>
                            </td>
                            <td><?php echo htmlspecialchars($row['descripcion']); ?></td>
                            <td><?php echo date('d/m/Y H:i', strtotime($row['fecha_reporte'])); ?></td>
                        </tr>
                    <?php endwhile; ?>
                    
                    <?php if (pg_num_rows($result) == 0): ?>
                        <tr>
                            <td colspan="4" style="text-align: center;">No hay incidencias registradas aún.</td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>

            <div style="margin-top: 30px; text-align: center;">
                <a href="registro_incidente.php" class="btn-primary" style="text-decoration: none; margin-right: 10px;">Nuevo Reporte</a>
                <a href="panel.php" style="color: #00d2ff; text-decoration: none;">Volver al Panel</a>
            </div>
        </div>
    </div>
</body>
</html>
