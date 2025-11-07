<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once __DIR__ . "/config.php";

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Gunakan metode POST"]);
    exit;
}

$input = json_decode(file_get_contents("php://input"), true);

if (!isset($input['nip']) || !isset($input['nama']) || !isset($input['email'])) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
    exit;
}

$nip = trim($input['nip']);
$nama = trim($input['nama']);
$email = trim($input['email']);
$matakuliah = trim($input['matakuliah'] ?? '');
$password = trim($input['password'] ?? '');

$conn = getOracleConnection();

if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit;
}

$sql = "UPDATE USERS
        SET USERNAME = :nama,
            EMAIL = :email,
            PRODI = :matakuliah,
            UPDATED_AT = CURRENT_TIMESTAMP";

if (!empty($password)) {
    $sql .= ", PASSWORD = :password";
}

$sql .= " WHERE NIM = :nip AND ROLE = 'dosen'";

$stmt = oci_parse($conn, $sql);

oci_bind_by_name($stmt, ":nama", $nama);
oci_bind_by_name($stmt, ":email", $email);
oci_bind_by_name($stmt, ":matakuliah", $matakuliah);
oci_bind_by_name($stmt, ":nip", $nip);

if (!empty($password)) {
    oci_bind_by_name($stmt, ":password", $password);
}

$exec = oci_execute($stmt, OCI_COMMIT_ON_SUCCESS);

if ($exec) {
    echo json_encode(["success" => true, "message" => "Data dosen berhasil diperbarui"]);
} else {
    $e = oci_error($stmt);
    echo json_encode(["success" => false, "message" => "Gagal update: " . $e['message']]);
}

oci_free_statement($stmt);
oci_close($conn);
?>
