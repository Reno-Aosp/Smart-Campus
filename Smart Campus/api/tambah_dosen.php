<?php
// api/tambah_dosen.php
// Pastikan file ini disimpan di folder api dan path config.php benar (./config.php atau ../config.php sesuai lokasi)
ob_start(); // tangkap semua output agar tidak merusak JSON
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");

// tangkap warnings dan notices jadi exception-like message
set_error_handler(function($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});

require_once __DIR__ . '/config.php'; // sesuaikan jika beda lokasi

$response = ["success" => false, "message" => "Unknown error"];

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception("Gunakan metode POST");
    }

    $raw = file_get_contents("php://input");
    if ($raw === false || trim($raw) === '') {
        throw new Exception("Input JSON kosong atau tidak diterima.");
    }

    $input = json_decode($raw, true);
    if (!is_array($input)) {
        throw new Exception("Input JSON tidak valid.");
    }

    // ambil field yang dibutuhkan
    $nim = trim($input['nip'] ?? $input['nim'] ?? '');
    $nama = trim($input['nama'] ?? '');
    $matakuliah = trim($input['matakuliah'] ?? '');
    $email = trim($input['email'] ?? '');
    $password = trim($input['password'] ?? '');

    if ($nim === '' || $nama === '' || $matakuliah === '' || $email === '' ) {
        throw new Exception("Semua kolom wajib diisi (NIP/NIM, Nama, Mata Kuliah, Email).");
    }

    // jika password dikirim kosong, boleh set default (atau tolak)
    if ($password === '') {
        // opsi: set default password, mis: "mhs123"
        $password = "mhs123";
    }

    // koneksi
    $conn = getOracleConnection();
    if (!$conn) throw new Exception("Koneksi database gagal.");

    // insert ke USERS (sesuaikan nama kolom sesuai DB)
    $sql = "INSERT INTO USERS (
                USERNAME, PASSWORD, EMAIL, ROLE, IS_ACTIVE, CREATED_AT,
                NIM, KELAS, PRODI
            ) VALUES (
                :username, :password, :email, 'dosen', 1, CURRENT_TIMESTAMP,
                :nim, :kelas, :prodi
            )";

    $stid = oci_parse($conn, $sql);
    if (!$stid) {
        $e = oci_error($conn);
        throw new Exception("OCI parse error: " . ($e['message'] ?? 'unknown'));
    }

    $kelas = "-"; // dosen tidak punya kelas
    // di here we store mata kuliah ke PRODI (sesuai keputusan sebelumnya)
    oci_bind_by_name($stid, ":username", $nama);
    oci_bind_by_name($stid, ":password", $password);
    oci_bind_by_name($stid, ":email", $email);
    oci_bind_by_name($stid, ":nim", $nim);
    oci_bind_by_name($stid, ":kelas", $kelas);
    oci_bind_by_name($stid, ":prodi", $matakuliah);

    $ok = oci_execute($stid, OCI_NO_AUTO_COMMIT);
    if (!$ok) {
        $err = oci_error($stid);
        throw new Exception("Gagal insert: " . ($err['message'] ?? 'unknown'));
    }
    oci_commit($conn);

    $response = ["success" => true, "message" => "Dosen berhasil ditambahkan"];
    oci_free_statement($stid);
    oci_close($conn);

} catch (Throwable $e) {
    // ambil semua output tak sengaja (warnings) agar bisa dilog, tapi jangan gabungkan ke JSON utama
    $ob = ob_get_clean();
    // simpan error message (jangan tunjukkan stack trace ke user), tapi untuk dev bisa sertakan
    $response = [
        "success" => false,
        "message" => $e->getMessage(),
        // untuk debugging sementara, sertakan raw output (hapus di production)
        "debug_output" => strlen($ob) ? substr($ob, 0, 2000) : null
    ];
    // jika koneksi ada, pastikan ditutup
    if (isset($stid) && is_resource($stid)) @oci_free_statement($stid);
    if (isset($conn) && $conn) @oci_close($conn);
}

// pastikan tidak ada output lain
ob_end_clean();
echo json_encode($response, JSON_UNESCAPED_UNICODE);
exit;
