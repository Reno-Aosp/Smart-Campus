<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once(__DIR__ . '/config.php');
$conn = getOracleConnection();

$raw = file_get_contents("php://input");
$input = json_decode($raw, true);

$user_id = $input['user_id'] ?? '';
$username = trim($input['username'] ?? '');
$email = trim($input['email'] ?? '');
$kelas = trim($input['kelas'] ?? '');
$prodi = trim($input['prodi'] ?? '');

if (!$user_id) {
    echo json_encode(["success" => false, "message" => "ID pengguna tidak valid"]);
    exit;
}

// Update tabel USERS
$sql_user = "UPDATE users SET username=:username, email=:email, kelas=:kelas, prodi=:prodi, updated_at=SYSTIMESTAMP WHERE user_id=:id";
$stid1 = oci_parse($conn, $sql_user);
oci_bind_by_name($stid1, ":username", $username);
oci_bind_by_name($stid1, ":email", $email);
oci_bind_by_name($stid1, ":kelas", $kelas);
oci_bind_by_name($stid1, ":prodi", $prodi);
oci_bind_by_name($stid1, ":id", $user_id);

if (!oci_execute($stid1, OCI_NO_AUTO_COMMIT)) {
    $err = oci_error($stid1);
    echo json_encode(["success" => false, "message" => "Gagal update USERS: " . $err['message']]);
    oci_rollback($conn);
    exit;
}

// Update tabel MAHASISWA (berdasarkan NIM yang sama)
$sql_mhs = "UPDATE mahasiswa SET email=:email, updated_at=SYSTIMESTAMP 
WHERE nim=(SELECT nim FROM users WHERE user_id=:id)";
$stid2 = oci_parse($conn, $sql_mhs);
oci_bind_by_name($stid2, ":email", $email);
oci_bind_by_name($stid2, ":id", $user_id);
oci_execute($stid2, OCI_NO_AUTO_COMMIT);

oci_commit($conn);
echo json_encode(["success" => true, "message" => "Data mahasiswa berhasil diperbarui"]);
oci_free_statement($stid1);
oci_free_statement($stid2);
oci_close($conn);
?>
