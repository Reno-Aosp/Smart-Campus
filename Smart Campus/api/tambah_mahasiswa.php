<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once(__DIR__ . '/config.php');

// 🔹 koneksi ke Oracle
$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal."]);
    exit;
}

// 🔹 ambil input JSON
$raw = file_get_contents("php://input");
if ($raw === false || trim($raw) === '') {
    echo json_encode(["success" => false, "message" => "Input JSON kosong atau tidak diterima."]);
    exit;
}

$input = json_decode($raw, true);
if (!is_array($input)) {
    echo json_encode(["success" => false, "message" => "Input JSON tidak valid.", "raw" => $raw]);
    exit;
}

// 🔹 ambil data dari form
$username = trim($input['username'] ?? '');
$password = trim($input['password'] ?? '');
$email    = trim($input['email'] ?? '');
$nim      = trim($input['nim'] ?? '');
$kelas    = trim($input['kelas'] ?? '');
$prodi    = trim($input['prodi'] ?? '');
$role     = 'mahasiswa';
$is_active = 1;

// 🔹 validasi dasar
if ($username === '' || $password === '' || $email === '' || $nim === '') {
    echo json_encode([
        "success" => false,
        "message" => "Username, Password, Email, dan NIM wajib diisi.",
        "received" => $input
    ]);
    exit;
}

// 🔹 (Opsional) gunakan password_hash agar lebih aman
// $password_to_store = password_hash($password, PASSWORD_DEFAULT);
$password_to_store = $password; // kalau belum mau pakai hash

// 🔹 query insert
$sql = "INSERT INTO users (
            username, password, email, role, is_active, nim, kelas, prodi, created_at
        ) VALUES (
            :username, :password, :email, :role, :is_active, :nim, :kelas, :prodi, SYSTIMESTAMP
        )";

$stid = oci_parse($conn, $sql);
if (!$stid) {
    $err = oci_error($conn);
    echo json_encode(["success" => false, "message" => "OCI parse error: " . $err['message']]);
    exit;
}

// 🔹 binding data
oci_bind_by_name($stid, ":username", $username);
oci_bind_by_name($stid, ":password", $password_to_store);
oci_bind_by_name($stid, ":email", $email);
oci_bind_by_name($stid, ":role", $role);
oci_bind_by_name($stid, ":is_active", $is_active);
oci_bind_by_name($stid, ":nim", $nim);
oci_bind_by_name($stid, ":kelas", $kelas);
oci_bind_by_name($stid, ":prodi", $prodi);

// 🔹 eksekusi dan commit
if (oci_execute($stid, OCI_NO_AUTO_COMMIT)) {
    oci_commit($conn);
    echo json_encode(["success" => true, "message" => "Mahasiswa berhasil ditambahkan ke tabel users."]);
} else {
    $err = oci_error($stid);
    echo json_encode(["success" => false, "message" => "Gagal insert: " . $err['message']]);
}

// 🔹 cleanup
oci_free_statement($stid);
oci_close($conn);
exit;
?>
