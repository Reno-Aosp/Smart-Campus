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
            NIM AS NIP,
            USERNAME,
            EMAIL,
            ROLE,
            IS_ACTIVE,
            NVL(PRODI, '-') AS PRODI,
            CREATED_AT
        FROM USERS
        WHERE ROLE = 'dosen'
        ORDER BY USER_ID";

$stid = oci_parse($conn, $sql);
oci_execute($stid);

$data = [];
while ($row = oci_fetch_assoc($stid)) {
    $data[] = [
        "user_id"  => $row["USER_ID"],
        "nip"      => $row["NIP"],
        "username" => $row["USERNAME"],
        "email"    => $row["EMAIL"],
        "prodi"    => $row["PRODI"]
    ];
}

oci_free_statement($stid);
oci_close($conn);

echo json_encode(["success" => true, "data" => $data]);
?>
