<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once('../config.php');

try {
  $input = json_decode(file_get_contents("php://input"), true);
  if (!$input) {
    echo json_encode(["success" => false, "message" => "Input JSON tidak valid"]);
    exit;
  }

  $nim   = trim($input['nim'] ?? '');
  $nama  = trim($input['nama'] ?? '');
  $kelas = trim($input['kelas'] ?? '');
  $prodi = trim($input['prodi'] ?? '');
  $email = trim($input['email'] ?? '');

  // Validasi sederhana
  if (!$nim || !$nama || !$email) {
    echo json_encode(["success" => false, "message" => "NIM, Nama, dan Email wajib diisi"]);
    exit;
  }

  if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi ke database gagal"]);
    exit;
  }

  // Default data
  $defaultPassword = '12345';
  $role = 'mahasiswa';
  $is_active = 1;

  // Query insert sesuai format tabel kamu
  $sql = "INSERT INTO users (username, password, email, role, is_active)
          VALUES (:username, :password, :email, :role, :is_active)";

  $stmt = oci_parse($conn, $sql);
  oci_bind_by_name($stmt, ":username", $nim);
  oci_bind_by_name($stmt, ":password", $defaultPassword);
  oci_bind_by_name($stmt, ":email", $email);
  oci_bind_by_name($stmt, ":role", $role);
  oci_bind_by_name($stmt, ":is_active", $is_active);

  $execute = oci_execute($stmt, OCI_NO_AUTO_COMMIT);

  if ($execute) {
    oci_commit($conn);
    echo json_encode(["success" => true, "message" => "Mahasiswa berhasil ditambahkan ke tabel users"]);
  } else {
    $err = oci_error($stmt);
    echo json_encode(["success" => false, "message" => "Gagal menambahkan: " . $err['message']]);
  }

  oci_free_statement($stmt);
  oci_close($conn);

} catch (Exception $e) {
  echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
?>
