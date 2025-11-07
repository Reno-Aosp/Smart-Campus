<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
require_once "config.php";

$conn = getOracleConnection();
if (!$conn) {
  echo json_encode(["success"=>false,"message"=>"Koneksi gagal"]);
  exit;
}

$data = [];

// 1) coba dari USERS (ROLE = 'dosen')
$sql1 = "SELECT USER_ID AS DOSEN_ID, NVL(NIM, '-') AS NIM, USERNAME AS NAME FROM USERS WHERE ROLE = 'dosen' ORDER BY USERNAME";
$stid1 = oci_parse($conn, $sql1);
oci_execute($stid1);
while ($r = oci_fetch_assoc($stid1)) {
  $data[] = ["dosen_id" => $r["DOSEN_ID"], "nim" => $r["NIM"], "name_display" => $r["NAME"]];
}
oci_free_statement($stid1);

// 2) jika tidak ada data dan ada tabel DOSEN, fallback (cek cepat apakah tabel DOSEN ada)
$sql_check = "SELECT COUNT(*) AS CNT FROM ALL_TABLES WHERE OWNER = (SELECT USER FROM DUAL) AND TABLE_NAME = 'DOSEN'";
$stidc = oci_parse($conn, $sql_check);
oci_execute($stidc);
$hasDosenTable = false;
if ($r = oci_fetch_assoc($stidc)) $hasDosenTable = ($r["CNT"] > 0);
oci_free_statement($stidc);

if (empty($data) && $hasDosenTable) {
  $sql2 = "SELECT DOSEN_ID, NIP, NAMA_DOSEN AS NAME FROM DOSEN ORDER BY NAMA_DOSEN";
  $stid2 = oci_parse($conn, $sql2);
  oci_execute($stid2);
  while ($r = oci_fetch_assoc($stid2)) {
    $data[] = ["dosen_id" => $r["DOSEN_ID"], "nim" => $r["NIP"], "name_display" => $r["NAME"]];
  }
  oci_free_statement($stid2);
}

oci_close($conn);
echo json_encode(["success"=>true,"data"=>$data]);
?>