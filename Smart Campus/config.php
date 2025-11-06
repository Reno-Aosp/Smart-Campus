<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$conn = oci_connect('uas', 'uas', 'localhost:1521/orcl');
if (!$conn) {
    $e = oci_error();
    echo "❌ Koneksi gagal: " . htmlentities($e['message']);
} else {
    echo "✅ Koneksi berhasil ke Oracle!";
    oci_close($conn);
}
?>