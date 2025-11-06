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
$data = json_decode($raw, true);

$user_id = $data['user_id'] ?? '';
$username = trim($data['username'] ?? '');
$email = trim($data['email'] ?? '');
$kelas = trim($data['kelas'] ?? '');
$prodi = trim($data['prodi'] ?? '');

if ($user_id === '' || $username === '' || $email === '') {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
    exit;
}

$sql = "UPDATE USERS
        SET USERNAME = :username, EMAIL = :email, KELAS = :kelas, PRODI = :prodi
        WHERE USER_ID = :user_id";

$stid = oci_parse($conn, $sql);
oci_bind_by_name($stid, ":username", $username);
oci_bind_by_name($stid, ":email", $email);
oci_bind_by_name($stid, ":kelas", $kelas);
oci_bind_by_name($stid, ":prodi", $prodi);
oci_bind_by_name($stid, ":user_id", $user_id);

if (oci_execute($stid, OCI_NO_AUTO_COMMIT)) {
    oci_commit($conn);
    echo json_encode(["success" => true, "message" => "Data mahasiswa berhasil diperbarui"]);
} else {
    $err = oci_error($stid);
    echo json_encode(["success" => false, "message" => "Gagal update: " . $err['message']]);
}

oci_free_statement($stid);
oci_close($conn);
?>