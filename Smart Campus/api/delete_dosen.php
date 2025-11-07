<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once __DIR__ . "/config.php";

$input = json_decode(file_get_contents("php://input"), true);
$nip = $input["nip"] ?? null;

if (!$nip) {
    echo json_encode(["success" => false, "message" => "NIP tidak dikirim"]);
    exit;
}

$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit;
}

// Gunakan kolom NIM karena di tabel kamu tidak ada kolom NIP
$sql = "DELETE FROM USERS WHERE NIM = :nip AND ROLE = 'dosen'";
$stid = oci_parse($conn, $sql);
oci_bind_by_name($stid, ":nip", $nip);

if (oci_execute($stid, OCI_COMMIT_ON_SUCCESS)) {
    echo json_encode(["success" => true, "message" => "Dosen berhasil dihapus"]);
} else {
    $e = oci_error($stid);
    echo json_encode(["success" => false, "message" => "Gagal menghapus dosen", "error" => $e['message']]);
}

oci_free_statement($stid);
oci_close($conn);
?>
