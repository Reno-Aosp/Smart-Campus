<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
require_once(__DIR__ . '/config.php');

$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal."]);
    exit;
}

$raw = file_get_contents("php://input");
$input = json_decode($raw, true);

$nip       = trim($input['nip'] ?? '');
$nama      = trim($input['nama'] ?? '');
$matakuliah= trim($input['matakuliah'] ?? '');
$email     = trim($input['email'] ?? '');
$password  = trim($input['password'] ?? '');
$role      = 'dosen';
$is_active = 1;

if ($nip === '' || $nama === '' || $email === '' || $password === '') {
    echo json_encode(["success" => false, "message" => "Semua kolom wajib diisi.", "received" => $input]);
    exit;
}

$sql = "INSERT INTO users (username, password, email, role, is_active, nim, kelas, prodi)
        VALUES (:username, :password, :email, :role, :is_active, :nim, :kelas, :prodi)";

$stid = oci_parse($conn, $sql);
oci_bind_by_name($stid, ":username", $nama);
oci_bind_by_name($stid, ":password", $password);
oci_bind_by_name($stid, ":email", $email);
oci_bind_by_name($stid, ":role", $role);
oci_bind_by_name($stid, ":is_active", $is_active);
oci_bind_by_name($stid, ":nim", $nip);
oci_bind_by_name($stid, ":kelas", $matakuliah); // mata kuliah disimpan di kolom kelas
oci_bind_by_name($stid, ":prodi", $matakuliah); // bisa pakai kolom ini kalau mau tampilkan juga

if (oci_execute($stid, OCI_NO_AUTO_COMMIT)) {
    oci_commit($conn); // ⬅️ penting! supaya data tidak hilang setelah script selesai
    echo json_encode(["success" => true, "message" => "Dosen berhasil ditambahkan."]);
} else {
    $err = oci_error($stid);
    echo json_encode(["success" => false, "message" => "Gagal insert: " . $err['message']]);
}

oci_free_statement($stid);
oci_close($conn);
?>