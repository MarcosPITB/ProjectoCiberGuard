<?php
session_start();
include("conexion.php");

$mensaje = "";
$tipo = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nombre = trim($_POST['nombre']);
    $empresa = trim($_POST['empresa']);
    $email = trim($_POST['email']);
    $password = $_POST['password'];

    if (empty($nombre) || empty($empresa) || empty($email) || empty($password)) {
        $mensaje = "Todos los campos son obligatorios.";
        $tipo = "error";
    } else {
        $consulta = pg_query_params($conn, "SELECT id FROM usuarios WHERE email = $1", array($email));

        if ($consulta && pg_num_rows($consulta) > 0) {
            $mensaje = "Ese correo ya está registrado.";
            $tipo = "error";
        } else {
            $password_hash = password_hash($password, PASSWORD_DEFAULT);

            // CORRECCIÓN: Usamos 'nombre_usuario' para coincidir con el SQL
            $insert = pg_query_params(
                $conn,
                "INSERT INTO usuarios (nombre_usuario, empresa, email, password) VALUES ($1, $2, $3, $4)",
                array($nombre, $empresa, $email, $password_hash)
            );

            if ($insert) {
                $mensaje = "Registro completado correctamente. Ya puedes iniciar sesión.";
                $tipo = "success";
            } else {
                $mensaje = "Error al registrar el usuario en la base de datos.";
                $tipo = "error";
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Registro | CyberGuard</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="form-wrapper">
  <div class="glass-card form-card">
    <h2>Crear cuenta</h2>
    <?php if (!empty($mensaje)): ?>
      <div class="alert <?php echo $tipo === 'success' ? 'alert-success' : 'alert-error'; ?>">
        <?php echo htmlspecialchars($mensaje); ?>
      </div>
    <?php endif; ?>
    <form method="POST">
      <div class="form-group">
        <label>Nombre de Usuario</label>
        <input type="text" name="nombre" class="form-control" required>
      </div>
      <div class="form-group">
        <label>Empresa</label>
        <input type="text" name="empresa" class="form-control" required>
      </div>
      <div class="form-group">
        <label>Correo electrónico</label>
        <input type="email" name="email" class="form-control" required>
      </div>
      <div class="form-group">
        <label>Contraseña</label>
        <input type="password" name="password" class="form-control" required>
      </div>
      <button type="submit" class="btn btn-primary" style="width:100%;">Registrarse</button>
    </form>
    <div class="form-footer">
      ¿Ya tienes cuenta? <a href="login.php">Inicia sesión</a>
    </div>
  </div>
</div>
</body>
</html>