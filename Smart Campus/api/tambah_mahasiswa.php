<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once(__DIR__ . '/config.php');
$conn = getOracleConnection();
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi database gagal"]);
    exit;
}

// Baca input JSON
$raw = file_get_contents("php://input");
if (!$raw) {
    echo json_encode(["success" => false, "message" => "Input JSON kosong"]);
    exit;
}

$input = json_decode($raw, true);
if (!is_array($input)) {
    echo json_encode(["success" => false, "message" => "Format JSON tidak valid"]);
    exit;
}

// Ambil data input
$username       = trim($input['username'] ?? '');
$password       = trim($input['password'] ?? '');
$nim            = trim($input['nim'] ?? '');
$nama           = trim($input['nama'] ?? '');
$email          = trim($input['email'] ?? '');
$kelas          = trim($input['kelas'] ?? '');
$prodi          = trim($input['prodi'] ?? '');
$role           = 'mahasiswa';
$no_telepon     = trim($input['no_telepon'] ?? '');
$alamat         = trim($input['alamat'] ?? '');
$tanggal_lahir  = trim($input['tanggal_lahir'] ?? '');
$jenis_kelamin  = trim($input['jenis_kelamin'] ?? '');
$angkatan       = trim($input['angkatan'] ?? '');
$semester       = trim($input['semester'] ?? '1');

// Validasi wajib
if ($username === '' || $password === '' || $nim === '' || $nama === '') {
    echo json_encode(["success" => false, "message" => "Username, Password, NIM, dan Nama wajib diisi"]);
    exit;
}

// Konversi jenis kelamin ke format DB
if (strtolower($jenis_kelamin) === 'laki-laki') {
    $jenis_kelamin = 'L';
} elseif (strtolower($jenis_kelamin) === 'perempuan') {
    $jenis_kelamin = 'P';
} else {
    $jenis_kelamin = 'L'; // default
}

// Cek duplikasi USERNAME atau NIM
$checkSql = "SELECT COUNT(*) AS CNT FROM users WHERE username = :username OR nim = :nim";
$checkStid = oci_parse($conn, $checkSql);
oci_bind_by_name($checkStid, ":username", $username);
oci_bind_by_name($checkStid, ":nim", $nim);
oci_execute($checkStid);
$row = oci_fetch_assoc($checkStid);
if ($row['CNT'] > 0) {
    echo json_encode(["success" => false, "message" => "Username atau NIM sudah terdaftar."]);
    oci_free_statement($checkStid);
    exit;
}
oci_free_statement($checkStid);

// Insert ke USERS
$sql_user = "INSERT INTO users (
    user_id, username, password, email, role, is_active, created_at, nim, kelas, prodi
) VALUES (
    users_seq.NEXTVAL, :username, :password, :email, :role, 1, SYSTIMESTAMP, :nim, :kelas, :prodi
)
RETURNING user_id INTO :user_id";

$stid_user = oci_parse($conn, $sql_user);
oci_bind_by_name($stid_user, ":username", $username);
oci_bind_by_name($stid_user, ":password", $password);
oci_bind_by_name($stid_user, ":email", $email);
oci_bind_by_name($stid_user, ":role", $role);
oci_bind_by_name($stid_user, ":nim", $nim);
oci_bind_by_name($stid_user, ":kelas", $kelas);
oci_bind_by_name($stid_user, ":prodi", $prodi);
oci_bind_by_name($stid_user, ":user_id", $user_id, 32);

if (!oci_execute($stid_user, OCI_NO_AUTO_COMMIT)) {
    $err = oci_error($stid_user);
    oci_rollback($conn);
    echo json_encode(["success" => false, "message" => "Gagal insert ke USERS: " . $err['message']]);
    exit;
}

// Tangani NULL tanggal_lahir
$tanggal_lahir_sql = !empty($tanggal_lahir) ? "TO_DATE(:tanggal_lahir, 'YYYY-MM-DD')" : "NULL";

// Insert ke MAHASISWA
$sql_mhs = "
INSERT INTO mahasiswa (
    mahasiswa_id, user_id, nim, nama_lengkap, prodi_id, email, no_telepon, alamat,
    tanggal_lahir, jenis_kelamin, angkatan, semester, status, created_at
) VALUES (
    mahasiswa_seq.NEXTVAL, :user_id, :nim, :nama,
    (SELECT prodi_id FROM program_studi WHERE nama_prodi = :prodi AND ROWNUM = 1),
    :email, :no_telepon, :alamat,
    $tanggal_lahir_sql, :jenis_kelamin, :angkatan, :semester,
    'Aktif', SYSTIMESTAMP
)";

$stid_mhs = oci_parse($conn, $sql_mhs);
oci_bind_by_name($stid_mhs, ":user_id", $user_id);
oci_bind_by_name($stid_mhs, ":nim", $nim);
oci_bind_by_name($stid_mhs, ":nama", $nama);
oci_bind_by_name($stid_mhs, ":prodi", $prodi);
oci_bind_by_name($stid_mhs, ":email", $email);
oci_bind_by_name($stid_mhs, ":no_telepon", $no_telepon);
oci_bind_by_name($stid_mhs, ":alamat", $alamat);
if (!empty($tanggal_lahir)) {
    oci_bind_by_name($stid_mhs, ":tanggal_lahir", $tanggal_lahir);
}
oci_bind_by_name($stid_mhs, ":jenis_kelamin", $jenis_kelamin);
oci_bind_by_name($stid_mhs, ":angkatan", $angkatan);
oci_bind_by_name($stid_mhs, ":semester", $semester);

if (!oci_execute($stid_mhs, OCI_NO_AUTO_COMMIT)) {
    $err = oci_error($stid_mhs);
    oci_rollback($conn);
    echo json_encode(["success" => false, "message" => "Gagal insert ke MAHASISWA: " . $err['message']]);
    exit;
}

oci_commit($conn);

echo json_encode([
    "success" => true,
    "message" => "Mahasiswa berhasil ditambahkan",
    "data" => [
        "user_id" => $user_id,
        "username" => $username,
        "nim" => $nim,
        "jenis_kelamin" => $jenis_kelamin
    ]
]);

oci_free_statement($stid_user);
oci_free_statement($stid_mhs);
oci_close($conn);
?>
