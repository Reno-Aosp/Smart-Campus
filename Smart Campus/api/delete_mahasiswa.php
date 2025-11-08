<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once(__DIR__ . '/config.php');
$conn = getOracleConnection();

$raw = file_get_contents("php://input");
$input = json_decode($raw, true);
$user_id = $input['user_id'] ?? '';

if (!$user_id) {
    echo json_encode(["success" => false, "message" => "ID pengguna tidak valid"]);
    exit;
}

// Ambil NIM dulu biar bisa hapus dua tabel
$sql_get = "SELECT nim FROM users WHERE user_id = :id";
$stid_get = oci_parse($conn, $sql_get);
oci_bind_by_name($stid_get, ":id", $user_id);
oci_execute($stid_get);
$row = oci_fetch_assoc($stid_get);
$nim = $row['NIM'] ?? null;

if (!$nim) {
    echo json_encode(["success" => false, "message" => "Data mahasiswa tidak ditemukan"]);
    exit;
}

// Hapus dari tabel MAHASISWA
$sql_mhs = "DELETE FROM mahasiswa WHERE nim = :nim";
$stid1 = oci_parse($conn, $sql_mhs);
oci_bind_by_name($stid1, ":nim", $nim);
oci_execute($stid1, OCI_NO_AUTO_COMMIT);

// Hapus dari tabel USERS
$sql_user = "DELETE FROM users WHERE user_id = :id";
$stid2 = oci_parse($conn, $sql_user);
oci_bind_by_name($stid2, ":id", $user_id);

if (!oci_execute($stid2, OCI_NO_AUTO_COMMIT)) {
    $err = oci_error($stid2);
    oci_rollback($conn);
    echo json_encode(["success" => false, "message" => "Gagal hapus data: " . $err['message']]);
    exit;
}

oci_commit($conn);
echo json_encode(["success" => true, "message" => "Mahasiswa berhasil dihapus"]);
oci_free_statement($stid1);
oci_free_statement($stid2);
oci_close($conn);
?>
