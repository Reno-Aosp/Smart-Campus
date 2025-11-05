-- =====================================================
-- STORED PROCEDURES AND FUNCTIONS
-- FOR SMART CAMPUS DATABASE
-- =====================================================

-- =====================================================
-- 1. PROCEDURE: Add New Student
-- =====================================================

CREATE OR REPLACE PROCEDURE sp_add_mahasiswa (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_nim IN VARCHAR2,
    p_nama_lengkap IN VARCHAR2,
    p_prodi_kode IN VARCHAR2,
    p_email IN VARCHAR2,
    p_no_telepon IN VARCHAR2,
    p_jenis_kelamin IN VARCHAR2,
    p_angkatan IN NUMBER,
    p_semester IN NUMBER
) AS
    v_user_id NUMBER;
    v_prodi_id NUMBER;
BEGIN
    -- Insert into users table
    INSERT INTO users (username, password, email, role, is_active)
    VALUES (p_username, p_password, p_email, 'mahasiswa', 1)
    RETURNING user_id INTO v_user_id;
    
    -- Get prodi_id
    SELECT prodi_id INTO v_prodi_id
    FROM program_studi
    WHERE kode_prodi = p_prodi_kode;
    
    -- Insert into mahasiswa table
    INSERT INTO mahasiswa (
        user_id, nim, nama_lengkap, prodi_id, email, no_telepon,
        jenis_kelamin, angkatan, semester, status
    ) VALUES (
        v_user_id, p_nim, p_nama_lengkap, v_prodi_id, p_email, p_no_telepon,
        p_jenis_kelamin, p_angkatan, p_semester, 'Aktif'
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Mahasiswa berhasil ditambahkan: ' || p_nama_lengkap);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- =====================================================
-- 2. PROCEDURE: Add New Lecturer
-- =====================================================

CREATE OR REPLACE PROCEDURE sp_add_dosen (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_nip IN VARCHAR2,
    p_nama_lengkap IN VARCHAR2,
    p_gelar_depan IN VARCHAR2,
    p_gelar_belakang IN VARCHAR2,
    p_email IN VARCHAR2,
    p_no_telepon IN VARCHAR2,
    p_jenis_kelamin IN VARCHAR2
) AS
    v_user_id NUMBER;
BEGIN
    -- Insert into users table
    INSERT INTO users (username, password, email, role, is_active)
    VALUES (p_username, p_password, p_email, 'dosen', 1)
    RETURNING user_id INTO v_user_id;
    
    -- Insert into dosen table
    INSERT INTO dosen (
        user_id, nip, nama_lengkap, gelar_depan, gelar_belakang,
        email, no_telepon, jenis_kelamin
    ) VALUES (
        v_user_id, p_nip, p_nama_lengkap, p_gelar_depan, p_gelar_belakang,
        p_email, p_no_telepon, p_jenis_kelamin
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dosen berhasil ditambahkan: ' || p_nama_lengkap);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- =====================================================
-- 3. PROCEDURE: Record Attendance
-- =====================================================

CREATE OR REPLACE PROCEDURE sp_record_absensi (
    p_jadwal_id IN NUMBER,
    p_nim IN VARCHAR2,
    p_tanggal IN DATE,
    p_status_kehadiran IN VARCHAR2,
    p_keterangan IN VARCHAR2 DEFAULT NULL
) AS
    v_mahasiswa_id NUMBER;
BEGIN
    -- Get mahasiswa_id from NIM
    SELECT mahasiswa_id INTO v_mahasiswa_id
    FROM mahasiswa
    WHERE nim = p_nim;
    
    -- Insert or update attendance
    MERGE INTO absensi a
    USING (
        SELECT p_jadwal_id AS jadwal_id,
               v_mahasiswa_id AS mahasiswa_id,
               p_tanggal AS tanggal
        FROM dual
    ) src
    ON (a.jadwal_id = src.jadwal_id AND
        a.mahasiswa_id = src.mahasiswa_id AND
        a.tanggal = src.tanggal)
    WHEN MATCHED THEN
        UPDATE SET status_kehadiran = p_status_kehadiran,
                   keterangan = p_keterangan,
                   updated_at = CURRENT_TIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (jadwal_id, mahasiswa_id, tanggal, status_kehadiran, keterangan)
        VALUES (p_jadwal_id, v_mahasiswa_id, p_tanggal, p_status_kehadiran, p_keterangan);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Absensi berhasil dicatat untuk NIM: ' || p_nim);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- =====================================================
-- 4. PROCEDURE: Input Grade
-- =====================================================

CREATE OR REPLACE PROCEDURE sp_input_nilai (
    p_nim IN VARCHAR2,
    p_kode_matkul IN VARCHAR2,
    p_tahun_ajaran IN VARCHAR2,
    p_nilai_tugas IN NUMBER,
    p_nilai_uts IN NUMBER,
    p_nilai_uas IN NUMBER
) AS
    v_mahasiswa_id NUMBER;
    v_matkul_id NUMBER;
BEGIN
    -- Get mahasiswa_id
    SELECT mahasiswa_id INTO v_mahasiswa_id
    FROM mahasiswa
    WHERE nim = p_nim;
    
    -- Get matkul_id
    SELECT matkul_id INTO v_matkul_id
    FROM mata_kuliah
    WHERE kode_matkul = p_kode_matkul;
    
    -- Insert or update nilai
    MERGE INTO nilai n
    USING (
        SELECT v_mahasiswa_id AS mahasiswa_id,
               v_matkul_id AS matkul_id,
               p_tahun_ajaran AS tahun_ajaran
        FROM dual
    ) src
    ON (n.mahasiswa_id = src.mahasiswa_id AND
        n.matkul_id = src.matkul_id AND
        n.tahun_ajaran = src.tahun_ajaran)
    WHEN MATCHED THEN
        UPDATE SET nilai_tugas = p_nilai_tugas,
                   nilai_uts = p_nilai_uts,
                   nilai_uas = p_nilai_uas
    WHEN NOT MATCHED THEN
        INSERT (mahasiswa_id, matkul_id, tahun_ajaran, nilai_tugas, nilai_uts, nilai_uas)
        VALUES (v_mahasiswa_id, v_matkul_id, p_tahun_ajaran, p_nilai_tugas, p_nilai_uts, p_nilai_uas);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Nilai berhasil diinput untuk NIM: ' || p_nim);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- =====================================================
-- 5. FUNCTION: Calculate GPA (IPK)
-- =====================================================

CREATE OR REPLACE FUNCTION fn_calculate_ipk (
    p_nim IN VARCHAR2
) RETURN NUMBER AS
    v_ipk NUMBER;
    v_total_bobot NUMBER := 0;
    v_total_sks NUMBER := 0;
    v_bobot NUMBER;
BEGIN
    FOR rec IN (
        SELECT n.grade, mk.sks
        FROM nilai n
        JOIN mahasiswa m ON n.mahasiswa_id = m.mahasiswa_id
        JOIN mata_kuliah mk ON n.matkul_id = mk.matkul_id
        WHERE m.nim = p_nim
          AND n.status = 'Lulus'
    ) LOOP
        -- Convert grade to bobot
        CASE rec.grade
            WHEN 'A' THEN v_bobot := 4.0;
            WHEN 'B' THEN v_bobot := 3.0;
            WHEN 'C' THEN v_bobot := 2.0;
            WHEN 'D' THEN v_bobot := 1.0;
            ELSE v_bobot := 0.0;
        END CASE;
        
        v_total_bobot := v_total_bobot + (v_bobot * rec.sks);
        v_total_sks := v_total_sks + rec.sks;
    END LOOP;
    
    IF v_total_sks > 0 THEN
        v_ipk := v_total_bobot / v_total_sks;
    ELSE
        v_ipk := 0;
    END IF;
    
    RETURN ROUND(v_ipk, 2);
END;
/

-- =====================================================
-- 6. FUNCTION: Get Attendance Percentage
-- =====================================================

CREATE OR REPLACE FUNCTION fn_get_attendance_percentage (
    p_nim IN VARCHAR2,
    p_kode_matkul IN VARCHAR2,
    p_tahun_ajaran IN VARCHAR2
) RETURN NUMBER AS
    v_total_pertemuan NUMBER := 0;
    v_hadir NUMBER := 0;
    v_percentage NUMBER;
BEGIN
    SELECT COUNT(*), 
           SUM(CASE WHEN a.status_kehadiran = 'Hadir' THEN 1 ELSE 0 END)
    INTO v_total_pertemuan, v_hadir
    FROM absensi a
    JOIN mahasiswa m ON a.mahasiswa_id = m.mahasiswa_id
    JOIN jadwal_kuliah j ON a.jadwal_id = j.jadwal_id
    JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
    WHERE m.nim = p_nim
      AND mk.kode_matkul = p_kode_matkul
      AND j.tahun_ajaran = p_tahun_ajaran;
    
    IF v_total_pertemuan > 0 THEN
        v_percentage := (v_hadir / v_total_pertemuan) * 100;
    ELSE
        v_percentage := 0;
    END IF;
    
    RETURN ROUND(v_percentage, 2);
END;
/

-- =====================================================
-- 7. VIEW: Student Dashboard
-- =====================================================

CREATE OR REPLACE VIEW vw_student_dashboard AS
SELECT 
    m.nim,
    m.nama_lengkap,
    m.email,
    ps.nama_prodi,
    k.nama_kelas,
    m.semester,
    m.angkatan,
    m.status
FROM mahasiswa m
JOIN program_studi ps ON m.prodi_id = ps.prodi_id
LEFT JOIN kelas_mahasiswa km ON m.mahasiswa_id = km.mahasiswa_id
LEFT JOIN kelas k ON km.kelas_id = k.kelas_id
WHERE m.status = 'Aktif';

-- =====================================================
-- 8. VIEW: Lecturer Dashboard
-- =====================================================

CREATE OR REPLACE VIEW vw_lecturer_dashboard AS
SELECT 
    d.nip,
    d.nama_lengkap AS nama_dosen,
    d.gelar_depan,
    d.gelar_belakang,
    d.email,
    COUNT(DISTINCT mk.matkul_id) AS jumlah_matkul,
    COUNT(DISTINCT j.jadwal_id) AS jumlah_jadwal
FROM dosen d
LEFT JOIN mata_kuliah mk ON d.dosen_id = mk.dosen_id
LEFT JOIN jadwal_kuliah j ON d.dosen_id = j.dosen_id
GROUP BY d.nip, d.nama_lengkap, d.gelar_depan, d.gelar_belakang, d.email;

-- =====================================================
-- 9. VIEW: Student Grades Report
-- =====================================================

CREATE OR REPLACE VIEW vw_student_grades AS
SELECT 
    m.nim,
    m.nama_lengkap AS nama_mahasiswa,
    mk.kode_matkul,
    mk.nama_matkul,
    mk.sks,
    n.nilai_tugas,
    n.nilai_uts,
    n.nilai_uas,
    n.nilai_akhir,
    n.grade,
    n.status,
    n.tahun_ajaran
FROM nilai n
JOIN mahasiswa m ON n.mahasiswa_id = m.mahasiswa_id
JOIN mata_kuliah mk ON n.matkul_id = mk.matkul_id
ORDER BY m.nim, mk.kode_matkul;

-- =====================================================
-- 10. VIEW: Attendance Report
-- =====================================================

CREATE OR REPLACE VIEW vw_attendance_report AS
SELECT 
    m.nim,
    m.nama_lengkap AS nama_mahasiswa,
    k.nama_kelas,
    mk.nama_matkul,
    d.nama_lengkap AS nama_dosen,
    a.tanggal,
    a.status_kehadiran,
    a.keterangan
FROM absensi a
JOIN mahasiswa m ON a.mahasiswa_id = m.mahasiswa_id
JOIN jadwal_kuliah j ON a.jadwal_id = j.jadwal_id
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN kelas k ON j.kelas_id = k.kelas_id
JOIN dosen d ON j.dosen_id = d.dosen_id
ORDER BY a.tanggal DESC, m.nim;

-- =====================================================
-- 11. VIEW: Course Schedule
-- =====================================================

CREATE OR REPLACE VIEW vw_jadwal_lengkap AS
SELECT 
    k.nama_kelas,
    mk.kode_matkul,
    mk.nama_matkul,
    mk.sks,
    d.nama_lengkap AS nama_dosen,
    j.hari,
    j.jam_mulai,
    j.jam_selesai,
    j.ruangan,
    j.tahun_ajaran
FROM jadwal_kuliah j
JOIN kelas k ON j.kelas_id = k.kelas_id
JOIN mata_kuliah mk ON j.matkul_id = mk.matkul_id
JOIN dosen d ON j.dosen_id = d.dosen_id
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

COMMIT;
