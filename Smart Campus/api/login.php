<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");

require_once(__DIR__ . "/config.php"); // Pastikan path-nya benar

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode(["success" => false, "message" => "Gunakan metode POST."]);
    exit;
}

// Baca input JSON
$raw = file_get_contents("php://input");
if (!$raw || trim($raw) === "") {
    echo json_encode(["success" => false, "message" => "Data JSON kosong atau tidak dikirim."]);
    exit;
}

$input = json_decode($raw, true);
if (!is_array($input)) {
    echo json_encode(["success" => false, "message" => "Format JSON tidak valid.", "raw" => $raw]);
    exit;
}

$username = trim($input["username"] ?? "");
$password = trim($input["password"] ?? "");

if ($username === "" || $password === "") {
    echo json_encode(["success" => false, "message" => "Username dan password wajib diisi."]);
    exit;
}

$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi ke database gagal."]);
    exit;
}

$sql = "SELECT user_id, username, password, role, is_active 
        FROM users 
        WHERE username = :username AND password = :password";

$stid = oci_parse($conn, $sql);
oci_bind_by_name($stid, ":username", $username);
oci_bind_by_name($stid, ":password", $password);
oci_execute($stid);

$row = oci_fetch_assoc($stid);

if ($row) {
    if ($row["IS_ACTIVE"] == 0) {
        $response = ["success" => false, "message" => "Akun tidak aktif."];
    } else {
        // Update last_login
        $update = oci_parse($conn, "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = :id");
        oci_bind_by_name($update, ":id", $row["USER_ID"]);
        oci_execute($update, OCI_NO_AUTO_COMMIT);
        oci_commit($conn);

        $response = [
            "success" => true,
            "message" => "Login berhasil.",
            "data" => [
                "user_id"  => $row["USER_ID"],
                "username" => $row["USERNAME"],
                "role"     => $row["ROLE"]
            ]
        ];
    }
} else {
    $response = ["success" => false, "message" => "Username atau password salah."];
}

oci_free_statement($stid);
oci_close($conn);

echo json_encode($response, JSON_UNESCAPED_UNICODE);
exit;
?>
