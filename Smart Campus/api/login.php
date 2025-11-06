<?php
require_once('./config.php');

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Gunakan metode POST"]);
    exit;
}

$input = json_decode(file_get_contents("php://input"), true);

if (!isset($input['username']) || !isset($input['password'])) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
    exit;
}

$username = trim($input['username']);
$password = trim($input['password']);

$conn = getOracleConnection();

// Query login sesuai struktur tabel kamu
$sql = "SELECT user_id, username, password, role, is_active 
        FROM users 
        WHERE username = :username AND password = :password";

$stmt = oci_parse($conn, $sql);
oci_bind_by_name($stmt, ":username", $username);
oci_bind_by_name($stmt, ":password", $password);
oci_execute($stmt);

$row = oci_fetch_assoc($stmt);

if ($row) {
    if ($row['IS_ACTIVE'] == 0) {
        $response = ["success" => false, "message" => "Akun tidak aktif"];
    } else {
        // Update last_login
        $update = oci_parse($conn, "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = :id");
        oci_bind_by_name($update, ":id", $row['USER_ID']);
        oci_execute($update);
        oci_commit($conn);

        $response = [
            "success" => true,
            "message" => "Login berhasil",
            "data" => [
                "user_id" => $row['USER_ID'],
                "username" => $row['USERNAME'],
                "role" => $row['ROLE']
            ]
        ];
    }
} else {
    $response = ["success" => false, "message" => "Username atau password salah"];
}

oci_free_statement($stmt);
oci_close($conn);

echo json_encode($response);
?>
