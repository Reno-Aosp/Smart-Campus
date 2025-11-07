<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
require_once "config.php";

$conn = getOracleConnection();
if (!$conn) { echo json_encode(["success"=>false,"message"=>"Koneksi gagal"]); exit; }

$raw = file_get_contents("php://input");
$in = json_decode($raw, true);
$id = isset($in['matkul_id']) ? (int)$in['matkul_id'] : 0;

if (!$id) { echo json_encode(["success"=>false,"message"=>"ID tidak diberikan"]); exit; }

$stid = oci_parse($conn, "DELETE FROM MATA_KULIAH WHERE MATKUL_ID = :id");
oci_bind_by_name($stid, ":id", $id);

if (oci_execute($stid, OCI_NO_AUTO_COMMIT)) {
  oci_commit($conn);
  echo json_encode(["success"=>true,"message"=>"Mata kuliah berhasil dihapus"]);
} else {
  $err = oci_error($stid);
  echo json_encode(["success"=>false,"message"=>$err['message'] ?? 'Delete gagal']);
}
oci_free_statement($stid);
oci_close($conn);
