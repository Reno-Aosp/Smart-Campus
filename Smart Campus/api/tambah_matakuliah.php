<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
require_once "config.php";

$conn = getOracleConnection();
if (!$conn) { echo json_encode(["success"=>false,"message"=>"Koneksi gagal"]); exit; }

$raw = file_get_contents("php://input");
$in = json_decode($raw, true);

$kode = trim($in['kode_matkul'] ?? '');
$nama = trim($in['nama_matkul'] ?? '');
$prodi_id = isset($in['prodi_id']) && $in['prodi_id'] !== '' ? (int)$in['prodi_id'] : 0;
$dosen_id = isset($in['dosen_id']) && $in['dosen_id'] !== '' ? (int)$in['dosen_id'] : null;
$sks = isset($in['sks']) ? (int)$in['sks'] : 0;
$semester = isset($in['semester']) ? (int)$in['semester'] : 0;
$jenis = trim($in['jenis_matkul'] ?? 'Wajib');
$deskripsi = trim($in['deskripsi'] ?? '');

if ($kode === '' || $nama === '' || !$prodi_id) {
  echo json_encode(["success"=>false,"message"=>"Kode, Nama, dan Program Studi wajib diisi"]);
  exit;
}

// validasi prodi exists
$stid = oci_parse($conn, "SELECT 1 FROM PROGRAM_STUDI WHERE PRODI_ID = :pid");
oci_bind_by_name($stid, ":pid", $prodi_id);
oci_execute($stid);
if (!oci_fetch($stid)) {
  oci_free_statement($stid);
  oci_close($conn);
  echo json_encode(["success"=>false,"message"=>"Program Studi tidak ditemukan"]);
  exit;
}
oci_free_statement($stid);

// validasi dosen jika diberikan (boleh null)
if ($dosen_id !== null && $dosen_id !== 0) {
  $found = false;
  // cek USERS
  $s1 = oci_parse($conn, "SELECT 1 FROM USERS WHERE USER_ID = :did");
  oci_bind_by_name($s1, ":did", $dosen_id);
  oci_execute($s1);
  if (oci_fetch($s1)) $found = true;
  oci_free_statement($s1);

  // jika belum ditemukan, cek tabel DOSEN (jika ada)
  if (!$found) {
    $scheck = oci_parse($conn, "SELECT COUNT(*) AS CNT FROM ALL_TABLES WHERE OWNER = (SELECT USER FROM DUAL) AND TABLE_NAME = 'DOSEN'");
    oci_execute($scheck);
    $hasDosen = false;
    if ($r = oci_fetch_assoc($scheck)) $hasDosen = ($r["CNT"] > 0);
    oci_free_statement($scheck);

    if ($hasDosen) {
      $s2 = oci_parse($conn, "SELECT 1 FROM DOSEN WHERE DOSEN_ID = :did2");
      oci_bind_by_name($s2, ":did2", $dosen_id);
      oci_execute($s2);
      if (oci_fetch($s2)) $found = true;
      oci_free_statement($s2);
    }
  }

  if (!$found) {
    oci_close($conn);
    echo json_encode(["success"=>false,"message"=>"Dosen tidak ditemukan (invalid dosen_id)"]);
    exit;
  }
}

// insert
$sql = "INSERT INTO MATA_KULIAH (KODE_MATKUL, NAMA_MATKUL, SKS, SEMESTER, PRODI_ID, DOSEN_ID, JENIS_MATKUL, DESKRIPSI, CREATED_AT)
        VALUES (:kode, :nama, :sks, :semester, :prodi, :dosen, :jenis, :deskripsi, SYSTIMESTAMP)";

$stid2 = oci_parse($conn, $sql);
oci_bind_by_name($stid2, ":kode", $kode);
oci_bind_by_name($stid2, ":nama", $nama);
oci_bind_by_name($stid2, ":sks", $sks);
oci_bind_by_name($stid2, ":semester", $semester);
oci_bind_by_name($stid2, ":prodi", $prodi_id);
oci_bind_by_name($stid2, ":dosen", $dosen_id);
oci_bind_by_name($stid2, ":jenis", $jenis);
oci_bind_by_name($stid2, ":deskripsi", $deskripsi);

if (oci_execute($stid2, OCI_NO_AUTO_COMMIT)) {
  oci_commit($conn);
  echo json_encode(["success"=>true,"message"=>"Mata kuliah berhasil ditambahkan"]);
} else {
  $err = oci_error($stid2);
  echo json_encode(["success"=>false,"message"=>$err['message'] ?? 'Insert gagal']);
}
oci_free_statement($stid2);
oci_close($conn);
