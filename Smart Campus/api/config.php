<?php
function getOracleConnection() {
    $username = "uas2";
    $password = "uas2";
    $connectionString = "localhost/orcl";

    $conn = oci_connect($username, $password, $connectionString);
    if (!$conn) {
        $e = oci_error();
        throw new Exception("Gagal konek ke Oracle: " . $e['message']);
    }
    return $conn;
}
?>
