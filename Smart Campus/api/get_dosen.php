<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
require_once(__DIR__ . '/config.php');

$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal."]);
    exit;
}

$sql = "SELECT 
            NIM AS NIP,
            USERNAME AS NAMA,
            KELAS AS MATAKULIAH,
            EMAIL
        FROM USERS
        WHERE ROLE = 'dosen'";

$stid = oci_parse($conn, $sql);
oci_execute($stid);

$data = [];
while ($row = oci_fetch_assoc($stid)) {
    $data[] = [
        "nip" => $row["NIP"],
        "nama" => $row["NAMA"],
        "matakuliah" => $row["MATAKULIAH"],
        "email" => $row["EMAIL"]
    ];
}

oci_free_statement($stid);
oci_close($conn);

echo json_encode(["success" => true, "data" => $data]);
?>
