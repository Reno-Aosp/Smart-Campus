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

if ($user_id === '') {
    echo json_encode(["success" => false, "message" => "User ID tidak diberikan"]);
    exit;
}

$sql = "DELETE FROM USERS WHERE USER_ID = :user_id";
$stid = oci_parse($conn, $sql);
oci_bind_by_name($stid, ":user_id", $user_id);

if (oci_execute($stid, OCI_NO_AUTO_COMMIT)) {
    oci_commit($conn);
    echo json_encode(["success" => true, "message" => "Mahasiswa berhasil dihapus"]);
} else {
    $err = oci_error($stid);
    echo json_encode(["success" => false, "message" => "Gagal menghapus: " . $err['message']]);
}

oci_free_statement($stid);
oci_close($conn);
?>