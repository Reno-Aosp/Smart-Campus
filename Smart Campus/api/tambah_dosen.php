<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");

require_once "config.php";
$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit;
}

$raw = file_get_contents("php://input");
$input = json_decode($raw, true);

$nip      = trim($input['nip'] ?? '');
$username = trim($input['username'] ?? '');
$email    = trim($input['email'] ?? '');
$password = trim($input['password'] ?? '');
$prodi    = trim($input['prodi'] ?? '');
$role     = 'dosen';
$is_active = 1;

if ($nip === '' || $username === '' || $email === '' || $password === '') {
    echo json_encode(["success" => false, "message" => "NIP, Username, Email, dan Password wajib diisi"]);
    exit;
}

// $password_hash = password_hash($password, PASSWORD_DEFAULT);
$password_hash = $password;

$sql = "INSERT INTO USERS (NIM, USERNAME, PASSWORD, EMAIL, ROLE, IS_ACTIVE, PRODI, CREATED_AT)
        VALUES (:nip, :username, :password, :email, :role, :is_active, :prodi, SYSTIMESTAMP)";

$stid = oci_parse($conn, $sql);
oci_bind_by_name($stid, ":nip", $nip);
oci_bind_by_name($stid, ":username", $username);
oci_bind_by_name($stid, ":password", $password_hash);
oci_bind_by_name($stid, ":email", $email);
oci_bind_by_name($stid, ":role", $role);
oci_bind_by_name($stid, ":is_active", $is_active);
oci_bind_by_name($stid, ":prodi", $prodi);

if (oci_execute($stid, OCI_NO_AUTO_COMMIT)) {
    oci_commit($conn);
    echo json_encode(["success" => true, "message" => "Dosen berhasil ditambahkan"]);
} else {
    $err = oci_error($stid);
    echo json_encode(["success" => false, "message" => "Gagal menambah dosen: " . $err['message']]);
}

oci_free_statement($stid);
oci_close($conn);
?>
