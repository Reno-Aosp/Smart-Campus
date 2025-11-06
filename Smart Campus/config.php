<?php
// Data koneksi
$username = 'uas';
$password = 'uas';
$connection_string = 'localhost:1521/orcl';

// Coba koneksi
$conn = oci_connect($username, $password, $connection_string);

if (!$conn) {
    $e = oci_error();
    echo "Koneksi gagal: " . htmlentities($e['message']);
} else {
    echo "Koneksi berhasil ke Oracle Database!";
}

// Tutup koneksi
// oci_close($conn);
?>
