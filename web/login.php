<?php
session_start();
include 'conexion.php';

$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $usuario = trim($_POST['usuario']);
    $password = $_POST['password'];

    // Consulta usando 'nombre_usuario' para coincidir con el SQL
    $query = "SELECT * FROM usuarios WHERE nombre_usuario = $1";
    $result = pg_query_params($conn, $query, array($usuario));

    if ($result && $user_data = pg_fetch_assoc($result)) {
        // Verificamos el hash de la contraseña
        if (password_verify($password, $user_data['password'])) {
            $_SESSION['usuario'] = $user_data['nombre_usuario'];
            $_SESSION['usuario_id'] = $user_data['id'];
            header("Location: panel.php");
            exit();
        } else {
            $error = "Contraseña incorrecta.";
        }
    } else {
        $error = "El usuario no existe.";
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Login | CyberGuard</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="form-wrapper">
        <div class="glass-card form-card">
            <h2>Iniciar Sesión</h2>
            <?php if($error) echo "<div class='alert alert-error'>$error</div>"; ?>
            <form method="POST">
                <div class="form-group">
                    <label>Usuario</label>
                    <input type="text" name="usuario" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Contraseña</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width:100%;">Entrar</button>
            </form>
            <div class="form-footer">
                ¿No tienes cuenta? <a href="registro.php">Regístrate aquí</a>
            </div>
        </div>
    </div>
</body>
</html>