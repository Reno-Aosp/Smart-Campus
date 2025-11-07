<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
require_once "config.php";

$conn = getOracleConnection();
if (!$conn) { 
  echo json_encode(["success" => false, "message" => "Koneksi ke database gagal"]); 
  exit; 
}

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

// Query utama
$sql = "SELECT 
          mk.MATKUL_ID,
          mk.KODE_MATKUL,
          mk.NAMA_MATKUL,
          mk.SKS,
          mk.SEMESTER,
          mk.PRODI_ID,
          mk.DOSEN_ID,
          mk.JENIS_MATKUL,
          mk.DESKRIPSI,
          p.NAMA_PRODI AS PRODI_NAMA,
          u.USERNAME AS DOSEN_NAMA
        FROM MATA_KULIAH mk
        LEFT JOIN PROGRAM_STUDI p ON mk.PRODI_ID = p.PRODI_ID
        LEFT JOIN USERS u ON mk.DOSEN_ID = u.USER_ID";

if ($id > 0) {
  $sql .= " WHERE mk.MATKUL_ID = :id";
}

$sql .= " ORDER BY mk.MATKUL_ID DESC";

$stid = oci_parse($conn, $sql);
if ($id > 0) {
  oci_bind_by_name($stid, ":id", $id);
}

if (!oci_execute($stid)) {
  $e = oci_error($stid);
  echo json_encode(["success" => false, "message" => $e['message']]);
  oci_free_statement($stid);
  oci_close($conn);
  exit;
}

$data = [];
while ($r = oci_fetch_assoc($stid)) {
  $data[] = [
    "matkul_id"    => $r["MATKUL_ID"],
    "kode_matkul"  => $r["KODE_MATKUL"],
    "nama_matkul"  => $r["NAMA_MATKUL"],
    "sks"          => $r["SKS"],
    "semester"     => $r["SEMESTER"],
    "prodi_id"     => $r["PRODI_ID"],
    "prodi"        => $r["PRODI_NAMA"],
    "dosen_id"     => $r["DOSEN_ID"],
    "dosen_name"   => $r["DOSEN_NAMA"],
    "jenis_matkul" => $r["JENIS_MATKUL"],
    "deskripsi"    => $r["DESKRIPSI"]
  ];
}

oci_free_statement($stid);
oci_close($conn);

echo json_encode(["success" => true, "data" => $data]);
?>
