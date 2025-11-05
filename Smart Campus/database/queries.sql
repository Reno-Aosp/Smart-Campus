-- =====================================================
-- USEFUL QUERIES FOR SMART CAMPUS DATABASE
-- =====================================================

-- =====================================================
-- ADMIN QUERIES
-- =====================================================

-- 1. Get all students with their program information
SELECT 
    m.nim,
    m.nama_lengkap,
    ps.nama_prodi,
    k.nama_kelas,
    m.semester,
    m.angkatan,
    m.status,
    m.email,
    m.no_telepon
FROM mahasiswa m
JOIN program_studi ps ON m.prodi_id = ps.prodi_id
LEFT JOIN kelas_mahasiswa km ON m.mahasiswa_id = km.mahasiswa_id
LEFT JOIN kelas k ON km.kelas_id = k.kelas_id
ORDER BY m.nim;

-- 2. Get all lecturers with course count
SELECT 
    d.nip,
    d.gelar_depan || ' ' || d.nama_lengkap || ', ' || d.gelar_belakang AS nama_lengkap,
    d.email,
    d.no_telepon,
    COUNT(DISTINCT mk.matkul_id) AS jumlah_matkul
FROM dosen d
LEFT JOIN mata_kuliah mk ON d.dosen_id = mk.dosen_id
GROUP BY d.nip, d.gelar_depan, d.nama_lengkap, d.gelar_belakang, d.email, d.no_telepon
ORDER BY d.nip;

-- 3. Get all courses with lecturer information
SELECT 
    mk.kode_matkul,
    mk.nama_matkul,
    ps.nama_prodi,
    mk.sks,
    mk.semester,
    d.nama_lengkap AS dosen_pengampu,
    mk.jenis_matkul
FROM mata_kuliah mk
JOIN program_studi ps ON mk.prodi_id = ps.prodi_id
LEFT JOIN dosen d ON mk.dosen_id = d.dosen_id
ORDER BY mk.kode_matkul;

-- 4. Get enrollment statistics by class
SELECT 
    k.nama_kelas,
    ps.nama_prodi,
    k.semester,
    k.tahun_ajaran,
    COUNT(km.mahasiswa_id) AS jumlah_mahasiswa
FROM kelas k
JOIN program_studi ps ON k.prodi_id = ps.prodi_id
LEFT JOIN kelas_mahasiswa km ON k.kelas_id = km.kelas_id
GROUP BY k.nama_kelas, ps.nama_prodi, k.semester, k.tahun_ajaran
ORDER BY k.nama_kelas;

-- 5. Get attendance statistics by course
SELECT 
    mk.nama_matkul,
    k.nama_kelas,
    COUNT(DISTINCT a.mahasiswa_id) AS jumlah_mahasiswa,
    COUNT(a.absensi_id) AS total_absensi,
    SUM(CASE WHEN a.status_kehadiran = 'Hadir' THEN 1 ELSE 0 END) AS hadir,
    SUM(CASE WHEN a.status_kehadiran = 'Izin' THEN 1 ELSE 0 END) AS izin,
    SUM(CASE WHEN a.status_kehadiran = 'Sakit' THEN 1 ELSE 0 END) AS sakit,
    SUM(CASE WHEN a.status_kehadiran = 'Alpa' THEN 1 ELSE 0 END) AS alpa
FROM absensi a
JOIN jadwal_kuliah j ON a.jadwal_id = j.jadwal_id
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN kelas k ON j.kelas_id = k.kelas_id
GROUP BY mk.nama_matkul, k.nama_kelas
ORDER BY mk.nama_matkul;

-- 6. Get grade distribution by course
SELECT 
    mk.kode_matkul,
    mk.nama_matkul,
    n.tahun_ajaran,
    COUNT(*) AS total_mahasiswa,
    SUM(CASE WHEN n.grade = 'A' THEN 1 ELSE 0 END) AS grade_a,
    SUM(CASE WHEN n.grade = 'B' THEN 1 ELSE 0 END) AS grade_b,
    SUM(CASE WHEN n.grade = 'C' THEN 1 ELSE 0 END) AS grade_c,
    SUM(CASE WHEN n.grade = 'D' THEN 1 ELSE 0 END) AS grade_d,
    SUM(CASE WHEN n.grade = 'E' THEN 1 ELSE 0 END) AS grade_e,
    ROUND(AVG(n.nilai_akhir), 2) AS rata_rata
FROM nilai n
JOIN mata_kuliah mk ON n.matkul_id = mk.matkul_id
GROUP BY mk.kode_matkul, mk.nama_matkul, n.tahun_ajaran
ORDER BY mk.kode_matkul;

-- =====================================================
-- LECTURER QUERIES
-- =====================================================

-- 7. Get lecturer's teaching schedule
SELECT 
    j.hari,
    j.jam_mulai,
    j.jam_selesai,
    mk.nama_matkul,
    k.nama_kelas,
    j.ruangan,
    j.tahun_ajaran
FROM jadwal_kuliah j
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN kelas k ON j.kelas_id = k.kelas_id
JOIN dosen d ON j.dosen_id = d.dosen_id
WHERE d.nip = '197812312022031001' -- Replace with actual NIP
ORDER BY 
    CASE j.hari
        WHEN 'Senin' THEN 1
        WHEN 'Selasa' THEN 2
        WHEN 'Rabu' THEN 3
        WHEN 'Kamis' THEN 4
        WHEN 'Jumat' THEN 5
        WHEN 'Sabtu' THEN 6
    END,
    j.jam_mulai;

-- 8. Get students in lecturer's class
SELECT 
    m.nim,
    m.nama_lengkap,
    k.nama_kelas,
    mk.nama_matkul,
    m.email,
    m.no_telepon
FROM mahasiswa m
JOIN kelas_mahasiswa km ON m.mahasiswa_id = km.mahasiswa_id
JOIN kelas k ON km.kelas_id = k.kelas_id
JOIN jadwal_kuliah j ON k.kelas_id = j.kelas_id
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN dosen d ON j.dosen_id = d.dosen_id
WHERE d.nip = '197812312022031001' -- Replace with actual NIP
  AND mk.kode_matkul = 'TI301' -- Replace with course code
ORDER BY m.nim;

-- 9. Get attendance list for specific date
SELECT 
    m.nim,
    m.nama_lengkap,
    a.tanggal,
    a.status_kehadiran,
    a.keterangan
FROM absensi a
JOIN mahasiswa m ON a.mahasiswa_id = m.mahasiswa_id
JOIN jadwal_kuliah j ON a.jadwal_id = j.jadwal_id
WHERE j.jadwal_id = 1 -- Replace with jadwal_id
  AND a.tanggal = TO_DATE('2024-11-04', 'YYYY-MM-DD')
ORDER BY m.nim;

-- 10. Get grades for lecturer's course
SELECT 
    m.nim,
    m.nama_lengkap,
    n.nilai_tugas,
    n.nilai_uts,
    n.nilai_uas,
    n.nilai_akhir,
    n.grade,
    n.status
FROM nilai n
JOIN mahasiswa m ON n.mahasiswa_id = m.mahasiswa_id
JOIN mata_kuliah mk ON n.matkul_id = mk.matkul_id
WHERE mk.kode_matkul = 'TI301' -- Replace with course code
  AND n.tahun_ajaran = '2024/2025'
ORDER BY m.nim;

-- =====================================================
-- STUDENT QUERIES
-- =====================================================

-- 11. Get student's schedule
SELECT 
    j.hari,
    j.jam_mulai,
    j.jam_selesai,
    mk.nama_matkul,
    d.nama_lengkap AS nama_dosen,
    j.ruangan
FROM jadwal_kuliah j
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN kelas k ON j.kelas_id = k.kelas_id
JOIN dosen d ON j.dosen_id = d.dosen_id
JOIN kelas_mahasiswa km ON k.kelas_id = km.kelas_id
JOIN mahasiswa m ON km.mahasiswa_id = m.mahasiswa_id
WHERE m.nim = '3122500012' -- Replace with actual NIM
ORDER BY 
    CASE j.hari
        WHEN 'Senin' THEN 1
        WHEN 'Selasa' THEN 2
        WHEN 'Rabu' THEN 3
        WHEN 'Kamis' THEN 4
        WHEN 'Jumat' THEN 5
        WHEN 'Sabtu' THEN 6
    END,
    j.jam_mulai;

-- 12. Get student's attendance history
SELECT 
    mk.nama_matkul,
    a.tanggal,
    j.hari,
    a.status_kehadiran,
    a.keterangan
FROM absensi a
JOIN jadwal_kuliah j ON a.jadwal_id = j.jadwal_id
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN mahasiswa m ON a.mahasiswa_id = m.mahasiswa_id
WHERE m.nim = '3122500012' -- Replace with actual NIM
ORDER BY a.tanggal DESC;

-- 13. Get student's attendance percentage by course
SELECT 
    mk.nama_matkul,
    COUNT(*) AS total_pertemuan,
    SUM(CASE WHEN a.status_kehadiran = 'Hadir' THEN 1 ELSE 0 END) AS hadir,
    ROUND(SUM(CASE WHEN a.status_kehadiran = 'Hadir' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS persentase_kehadiran
FROM absensi a
JOIN jadwal_kuliah j ON a.jadwal_id = j.jadwal_id
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN mahasiswa m ON a.mahasiswa_id = m.mahasiswa_id
WHERE m.nim = '3122500012' -- Replace with actual NIM
GROUP BY mk.nama_matkul
ORDER BY mk.nama_matkul;

-- 14. Get student's grades
SELECT 
    mk.kode_matkul,
    mk.nama_matkul,
    mk.sks,
    n.nilai_tugas,
    n.nilai_uts,
    n.nilai_uas,
    n.nilai_akhir,
    n.grade,
    n.status
FROM nilai n
JOIN mata_kuliah mk ON n.matkul_id = mk.matkul_id
JOIN mahasiswa m ON n.mahasiswa_id = m.mahasiswa_id
WHERE m.nim = '3122500012' -- Replace with actual NIM
ORDER BY mk.kode_matkul;

-- 15. Get student's GPA (IPK)
SELECT 
    m.nim,
    m.nama_lengkap,
    fn_calculate_ipk(m.nim) AS ipk,
    SUM(mk.sks) AS total_sks
FROM mahasiswa m
JOIN nilai n ON m.mahasiswa_id = n.mahasiswa_id
JOIN mata_kuliah mk ON n.matkul_id = mk.matkul_id
WHERE m.nim = '3122500012' -- Replace with actual NIM
  AND n.status = 'Lulus'
GROUP BY m.nim, m.nama_lengkap;

-- 16. Get student profile
SELECT 
    m.nim,
    m.nama_lengkap,
    ps.nama_prodi,
    k.nama_kelas,
    m.semester,
    m.angkatan,
    m.email,
    m.no_telepon,
    m.alamat,
    m.status
FROM mahasiswa m
JOIN program_studi ps ON m.prodi_id = ps.prodi_id
LEFT JOIN kelas_mahasiswa km ON m.mahasiswa_id = km.mahasiswa_id
LEFT JOIN kelas k ON km.kelas_id = k.kelas_id
WHERE m.nim = '3122500012'; -- Replace with actual NIM

-- =====================================================
-- REPORT QUERIES
-- =====================================================

-- 17. Monthly attendance report
SELECT 
    TO_CHAR(a.tanggal, 'YYYY-MM') AS bulan,
    COUNT(*) AS total_absensi,
    SUM(CASE WHEN a.status_kehadiran = 'Hadir' THEN 1 ELSE 0 END) AS hadir,
    SUM(CASE WHEN a.status_kehadiran = 'Izin' THEN 1 ELSE 0 END) AS izin,
    SUM(CASE WHEN a.status_kehadiran = 'Sakit' THEN 1 ELSE 0 END) AS sakit,
    SUM(CASE WHEN a.status_kehadiran = 'Alpa' THEN 1 ELSE 0 END) AS alpa
FROM absensi a
GROUP BY TO_CHAR(a.tanggal, 'YYYY-MM')
ORDER BY bulan DESC;

-- 18. Top 10 students by GPA
SELECT 
    m.nim,
    m.nama_lengkap,
    ps.nama_prodi,
    m.semester,
    fn_calculate_ipk(m.nim) AS ipk
FROM mahasiswa m
JOIN program_studi ps ON m.prodi_id = ps.prodi_id
WHERE m.status = 'Aktif'
ORDER BY fn_calculate_ipk(m.nim) DESC
FETCH FIRST 10 ROWS ONLY;

-- 19. Students with low attendance (< 75%)
SELECT 
    m.nim,
    m.nama_lengkap,
    mk.nama_matkul,
    fn_get_attendance_percentage(m.nim, mk.kode_matkul, '2024/2025') AS persentase_kehadiran
FROM mahasiswa m
CROSS JOIN mata_kuliah mk
WHERE fn_get_attendance_percentage(m.nim, mk.kode_matkul, '2024/2025') < 75
  AND fn_get_attendance_percentage(m.nim, mk.kode_matkul, '2024/2025') > 0
ORDER BY persentase_kehadiran;

-- 20. Course performance report
SELECT 
    mk.kode_matkul,
    mk.nama_matkul,
    COUNT(n.nilai_id) AS jumlah_mahasiswa,
    ROUND(AVG(n.nilai_akhir), 2) AS rata_rata_nilai,
    MIN(n.nilai_akhir) AS nilai_terendah,
    MAX(n.nilai_akhir) AS nilai_tertinggi,
    SUM(CASE WHEN n.status = 'Lulus' THEN 1 ELSE 0 END) AS lulus,
    SUM(CASE WHEN n.status = 'Belum Lulus' THEN 1 ELSE 0 END) AS tidak_lulus
FROM mata_kuliah mk
LEFT JOIN nilai n ON mk.matkul_id = n.matkul_id
WHERE n.tahun_ajaran = '2024/2025'
GROUP BY mk.kode_matkul, mk.nama_matkul
ORDER BY mk.kode_matkul;

COMMIT;
