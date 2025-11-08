<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");

require_once(__DIR__ . '/config.php');
$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit;
}

$sql = "
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.kelas,
    u.prodi,
    m.mahasiswa_id,
    m.nim,
    m.nama_lengkap
FROM users u
JOIN mahasiswa m ON u.nim = m.nim
WHERE u.role = 'mahasiswa'
ORDER BY m.nama_lengkap
";

$stid = oci_parse($conn, $sql);
oci_execute($stid);

$data = [];
while ($row = oci_fetch_assoc($stid)) {
    $data[] = array_change_key_case($row, CASE_LOWER); // ✅ kunci jadi huruf kecil semua
}

echo json_encode(["success" => true, "data" => $data]);
oci_free_statement($stid);
oci_close($conn);
?>
