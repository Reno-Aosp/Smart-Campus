<?php
// config.php

define('DB_USER', 'uas2');
define('DB_PASS', 'uas2');
define('DB_CONN', 'localhost/orcl');

function getOracleConnection() {
    $conn = oci_connect(DB_USER, DB_PASS, DB_CONN);
    if (!$conn) {
        $e = oci_error();
        die("Koneksi gagal: " . $e['message']);
    }
    return $conn;
}
?>
