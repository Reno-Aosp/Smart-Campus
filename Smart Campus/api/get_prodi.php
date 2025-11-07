<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
require_once "config.php";

$conn = getOracleConnection();
if (!$conn) {
  echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
  exit;
}

$sql = "SELECT PRODI_ID, NAMA_PRODI FROM PROGRAM_STUDI ORDER BY NAMA_PRODI";
$stid = oci_parse($conn, $sql);
oci_execute($stid);

$data = [];
while ($row = oci_fetch_assoc($stid)) {
  $data[] = [
    "prodi_id" => $row["PRODI_ID"],
    "nama_prodi" => $row["NAMA_PRODI"]
  ];
}

oci_free_statement($stid);
oci_close($conn);

echo json_encode(["success" => true, "data" => $data]);
?>
