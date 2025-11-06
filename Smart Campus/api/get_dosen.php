<?php
ob_start();
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");
require_once __DIR__ . "/config.php";

$response = ["success" => false, "message" => "Unknown error", "data" => []];

try {
    $conn = getOracleConnection();
    if (!$conn) {
        throw new Exception("Koneksi ke database gagal");
    }

    $sql = "SELECT 
                USER_ID,
                USERNAME,
                EMAIL,
                ROLE,
                NVL(NIM, '-') AS NIM,
                NVL(KELAS, '-') AS KELAS,
                NVL(PRODI, '-') AS PRODI,
                NVL(TO_CHAR(CREATED_AT, 'YYYY-MM-DD HH24:MI:SS'), '-') AS CREATED_AT
            FROM USERS
            WHERE ROLE = 'dosen'
            ORDER BY USER_ID";

    $stid = oci_parse($conn, $sql);
    if (!$stid) {
        $e = oci_error($conn);
        throw new Exception("Gagal parse SQL: " . ($e['message'] ?? ''));
    }

    $exec = oci_execute($stid);
    if (!$exec) {
        $e = oci_error($stid);
        throw new Exception("Gagal eksekusi SQL: " . ($e['message'] ?? ''));
    }

    $data = [];
    while ($row = oci_fetch_assoc($stid)) {
        $data[] = [
            "user_id"   => $row["USER_ID"],
            "username"  => $row["USERNAME"],
            "email"     => $row["EMAIL"],
            "nim"       => $row["NIM"],
            "kelas"     => $row["KELAS"],
            "prodi"     => $row["PRODI"],
            "created_at"=> $row["CREATED_AT"]
        ];
    }

    $response = [
        "success" => true,
        "data"    => $data,
        "message" => count($data) ? "Data dosen ditemukan" : "Belum ada data dosen"
    ];

    oci_free_statement($stid);
    oci_close($conn);

} catch (Throwable $e) {
    $debug = ob_get_clean();
    $response = [
        "success" => false,
        "message" => $e->getMessage(),
        "debug"   => strlen($debug) ? substr($debug, 0, 2000) : null
    ];
}

ob_end_clean();
echo json_encode($response, JSON_UNESCAPED_UNICODE);
exit;
?>
