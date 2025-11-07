<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
require_once "config.php";

$conn = getOracleConnection();
if (!$conn) { echo json_encode(["success"=>false,"message"=>"Koneksi gagal"]); exit; }

$raw = file_get_contents("php://input");
$in = json_decode($raw, true);

$id = isset($in['matkul_id']) ? (int)$in['matkul_id'] : 0;
$kode = trim($in['kode_matkul'] ?? '');
$nama = trim($in['nama_matkul'] ?? '');
$prodi_id = isset($in['prodi_id']) && $in['prodi_id'] !== '' ? (int)$in['prodi_id'] : 0;
$dosen_id = isset($in['dosen_id']) && $in['dosen_id'] !== '' ? (int)$in['dosen_id'] : null;
$sks = isset($in['sks']) ? (int)$in['sks'] : 0;
$semester = isset($in['semester']) ? (int)$in['semester'] : 0;
$jenis = trim($in['jenis_matkul'] ?? 'Wajib');
$deskripsi = trim($in['deskripsi'] ?? '');

if (!$id || $kode === '' || $nama === '') {
  echo json_encode(["success"=>false,"message"=>"Data tidak lengkap"]);
  exit;
}

// cek exist matkul
$s0 = oci_parse($conn, "SELECT 1 FROM MATA_KULIAH WHERE MATKUL_ID = :id");
oci_bind_by_name($s0, ":id", $id);
oci_execute($s0);
if (!oci_fetch($s0)) {
  oci_free_statement($s0);
  oci_close($conn);
  echo json_encode(["success"=>false,"message"=>"Mata kuliah tidak ditemukan"]);
  exit;
}
oci_free_statement($s0);

// cek prodi
$s1 = oci_parse($conn, "SELECT 1 FROM PROGRAM_STUDI WHERE PRODI_ID = :pid");
oci_bind_by_name($s1, ":pid", $prodi_id);
oci_execute($s1);
if (!oci_fetch($s1)) {
  oci_free_statement($s1);
  oci_close($conn);
  echo json_encode(["success"=>false,"message"=>"Program Studi tidak ditemukan"]);
  exit;
}
oci_free_statement($s1);

// cek dosen jika ada
if ($dosen_id !== null && $dosen_id !== 0) {
  $found = false;
  $s2 = oci_parse($conn, "SELECT 1 FROM USERS WHERE USER_ID = :did");
  oci_bind_by_name($s2, ":did", $dosen_id);
  oci_execute($s2);
  if (oci_fetch($s2)) $found = true;
  oci_free_statement($s2);

  if (!$found) {
    $scheck = oci_parse($conn, "SELECT COUNT(*) AS CNT FROM ALL_TABLES WHERE OWNER=(SELECT USER FROM DUAL) AND TABLE_NAME='DOSEN'");
    oci_execute($scheck);
    $hasDosen = false;
    if ($r = oci_fetch_assoc($scheck)) $hasDosen = ($r['CNT'] > 0);
    oci_free_statement($scheck);

    if ($hasDosen) {
      $s3 = oci_parse($conn, "SELECT 1 FROM DOSEN WHERE DOSEN_ID = :did2");
      oci_bind_by_name($s3, ":did2", $dosen_id);
      oci_execute($s3);
      if (oci_fetch($s3)) $found = true;
      oci_free_statement($s3);
    }
  }

  if (!$found) {
    oci_close($conn);
    echo json_encode(["success"=>false,"message"=>"Dosen tidak ditemukan (invalid dosen_id)"]);
    exit;
  }
}

$sql = "UPDATE MATA_KULIAH SET KODE_MATKUL = :kode, NAMA_MATKUL = :nama, SKS = :sks, SEMESTER = :semester,
        PRODI_ID = :prodi, DOSEN_ID = :dosen, JENIS_MATKUL = :jenis, DESKRIPSI = :deskripsi, UPDATED_AT = SYSTIMESTAMP
        WHERE MATKUL_ID = :id";

$stid = oci_parse($conn, $sql);
oci_bind_by_name($stid, ":kode", $kode);
oci_bind_by_name($stid, ":nama", $nama);
oci_bind_by_name($stid, ":sks", $sks);
oci_bind_by_name($stid, ":semester", $semester);
oci_bind_by_name($stid, ":prodi", $prodi_id);
oci_bind_by_name($stid, ":dosen", $dosen_id);
oci_bind_by_name($stid, ":jenis", $jenis);
oci_bind_by_name($stid, ":deskripsi", $deskripsi);
oci_bind_by_name($stid, ":id", $id);

if (oci_execute($stid, OCI_NO_AUTO_COMMIT)) {
  oci_commit($conn);
  echo json_encode(["success"=>true,"message"=>"Mata kuliah berhasil diperbarui"]);
} else {
  $err = oci_error($stid);
  echo json_encode(["success"=>false,"message"=>$err['message'] ?? 'Update gagal']);
}
oci_free_statement($stid);
oci_close($conn);
