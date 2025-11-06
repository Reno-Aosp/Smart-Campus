<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
require_once "config.php";

$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit;
}

$sql = "SELECT 
            USER_ID, 
            NIM, 
            USERNAME, 
            EMAIL, 
            ROLE, 
            IS_ACTIVE, 
            CREATED_AT,
            NVL(KELAS, '-') AS KELAS,
            NVL(PRODI, '-') AS PRODI
        FROM USERS 
        WHERE ROLE = 'mahasiswa'
        ORDER BY USER_ID";

$stid = oci_parse($conn, $sql);
oci_execute($stid);

$data = [];
while ($row = oci_fetch_assoc($stid)) {
    $data[] = [
        "user_id"   => $row["USER_ID"],
        "nim"       => $row["NIM"],        // 🔹 sekarang ambil dari kolom NIM
        "username"  => $row["USERNAME"],   // 🔹 username tetap dari kolom USERNAME
        "email"     => $row["EMAIL"],
        "kelas"     => $row["KELAS"],
        "prodi"     => $row["PRODI"]
    ];
}

oci_free_statement($stid);
oci_close($conn);

echo json_encode(["success" => true, "data" => $data]);
?>
