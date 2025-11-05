-- =====================================================
-- SAMPLE DATA FOR SMART CAMPUS DATABASE
-- =====================================================

-- =====================================================
-- INSERT SAMPLE USERS
-- =====================================================

-- Admin user (password: admin123)
INSERT INTO users (username, password, email, role, is_active)
VALUES ('admin', 'admin123', 'admin@smartcampus.ac.id', 'admin', 1);

-- Dosen users (password: dosen123)
INSERT INTO users (username, password, email, role, is_active)
VALUES ('budi.santoso', 'dosen123', 'budi.santoso@poli.example.com', 'dosen', 1);

INSERT INTO users (username, password, email, role, is_active)
VALUES ('sri.wulandari', 'dosen123', 'sri.wulandari@poli.example.com', 'dosen', 1);

-- Mahasiswa users (password: mhs123)
INSERT INTO users (username, password, email, role, is_active)
VALUES ('3122500012', 'mhs123', 'rozaq@example.com', 'mahasiswa', 1);

INSERT INTO users (username, password, email, role, is_active)
VALUES ('3122500013', 'mhs123', 'rahma@example.com', 'mahasiswa', 1);

-- =====================================================
-- INSERT PROGRAM STUDI
-- =====================================================

INSERT INTO program_studi (kode_prodi, nama_prodi, jenjang, fakultas)
VALUES ('TI', 'Teknik Informatika', 'D3', 'Teknik');

INSERT INTO program_studi (kode_prodi, nama_prodi, jenjang, fakultas)
VALUES ('SI', 'Sistem Informasi', 'D3', 'Teknik');

INSERT INTO program_studi (kode_prodi, nama_prodi, jenjang, fakultas)
VALUES ('TK', 'Teknik Komputer', 'D3', 'Teknik');

-- =====================================================
-- INSERT DOSEN
-- =====================================================

INSERT INTO dosen (user_id, nip, nama_lengkap, gelar_depan, gelar_belakang, email, no_telepon, jenis_kelamin)
VALUES (
    (SELECT user_id FROM users WHERE username = 'budi.santoso'),
    '197812312022031001',
    'Budi Santoso',
    'Dr.',
    'M.Kom',
    'budi.santoso@poli.example.com',
    '081234567890',
    'L'
);

INSERT INTO dosen (user_id, nip, nama_lengkap, gelar_belakang, email, no_telepon, jenis_kelamin)
VALUES (
    (SELECT user_id FROM users WHERE username = 'sri.wulandari'),
    '198902202019021002',
    'Sri Wulandari',
    'M.Kom',
    'sri.wulandari@poli.example.com',
    '081234567891',
    'P'
);

-- =====================================================
-- INSERT MAHASISWA
-- =====================================================

INSERT INTO mahasiswa (user_id, nim, nama_lengkap, prodi_id, email, no_telepon, jenis_kelamin, angkatan, semester, status)
VALUES (
    (SELECT user_id FROM users WHERE username = '3122500012'),
    '3122500012',
    'Muhammad Rozaq Ma''ruf',
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TI'),
    'rozaq@example.com',
    '081234567892',
    'L',
    2022,
    5,
    'Aktif'
);

INSERT INTO mahasiswa (user_id, nim, nama_lengkap, prodi_id, email, no_telepon, jenis_kelamin, angkatan, semester, status)
VALUES (
    (SELECT user_id FROM users WHERE username = '3122500013'),
    '3122500013',
    'Siti Rahma',
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TI'),
    'rahma@example.com',
    '081234567893',
    'P',
    2022,
    5,
    'Aktif'
);

-- =====================================================
-- INSERT KELAS
-- =====================================================

INSERT INTO kelas (kode_kelas, nama_kelas, prodi_id, semester, tahun_ajaran)
VALUES (
    'TI-3A',
    'TI-3A',
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TI'),
    5,
    '2024/2025'
);

INSERT INTO kelas (kode_kelas, nama_kelas, prodi_id, semester, tahun_ajaran)
VALUES (
    'TI-3B',
    'TI-3B',
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TI'),
    5,
    '2024/2025'
);

-- =====================================================
-- INSERT MATA KULIAH
-- =====================================================

INSERT INTO mata_kuliah (kode_matkul, nama_matkul, sks, semester, prodi_id, dosen_id, jenis_matkul)
VALUES (
    'TI301',
    'Pemrograman Web',
    3,
    5,
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TI'),
    (SELECT dosen_id FROM dosen WHERE nip = '197812312022031001'),
    'Wajib'
);

INSERT INTO mata_kuliah (kode_matkul, nama_matkul, sks, semester, prodi_id, dosen_id, jenis_matkul)
VALUES (
    'TI305',
    'Basis Data Lanjut',
    3,
    5,
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TI'),
    (SELECT dosen_id FROM dosen WHERE nip = '198902202019021002'),
    'Wajib'
);

INSERT INTO mata_kuliah (kode_matkul, nama_matkul, sks, semester, prodi_id, dosen_id, jenis_matkul)
VALUES (
    'TI302',
    'Jaringan Komputer',
    3,
    5,
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TI'),
    (SELECT dosen_id FROM dosen WHERE nip = '197812312022031001'),
    'Wajib'
);

-- =====================================================
-- INSERT KELAS_MAHASISWA (Enrollment)
-- =====================================================

INSERT INTO kelas_mahasiswa (kelas_id, mahasiswa_id, tahun_ajaran, status)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TI-3A'),
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500012'),
    '2024/2025',
    'Aktif'
);

INSERT INTO kelas_mahasiswa (kelas_id, mahasiswa_id, tahun_ajaran, status)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TI-3B'),
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500013'),
    '2024/2025',
    'Aktif'
);

-- =====================================================
-- INSERT JADWAL KULIAH
-- =====================================================

INSERT INTO jadwal_kuliah (kelas_id, matkul_id, dosen_id, hari, jam_mulai, jam_selesai, ruangan, tahun_ajaran)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TI-3A'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TI301'),
    (SELECT dosen_id FROM dosen WHERE nip = '197812312022031001'),
    'Senin',
    '08:00',
    '09:40',
    'D203',
    '2024/2025'
);

INSERT INTO jadwal_kuliah (kelas_id, matkul_id, dosen_id, hari, jam_mulai, jam_selesai, ruangan, tahun_ajaran)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TI-3A'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TI302'),
    (SELECT dosen_id FROM dosen WHERE nip = '197812312022031001'),
    'Selasa',
    '10:00',
    '11:40',
    'D204',
    '2024/2025'
);

INSERT INTO jadwal_kuliah (kelas_id, matkul_id, dosen_id, hari, jam_mulai, jam_selesai, ruangan, tahun_ajaran)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TI-3A'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TI305'),
    (SELECT dosen_id FROM dosen WHERE nip = '198902202019021002'),
    'Rabu',
    '13:00',
    '14:40',
    'D205',
    '2024/2025'
);

-- =====================================================
-- INSERT ABSENSI (Sample attendance data)
-- =====================================================

INSERT INTO absensi (jadwal_id, mahasiswa_id, tanggal, status_kehadiran, keterangan)
VALUES (
    1,
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500012'),
    TO_DATE('2024-11-04', 'YYYY-MM-DD'),
    'Hadir',
    NULL
);

INSERT INTO absensi (jadwal_id, mahasiswa_id, tanggal, status_kehadiran, keterangan)
VALUES (
    1,
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500012'),
    TO_DATE('2024-10-28', 'YYYY-MM-DD'),
    'Hadir',
    NULL
);

-- =====================================================
-- INSERT NILAI (Sample grades)
-- =====================================================

INSERT INTO nilai (mahasiswa_id, matkul_id, tahun_ajaran, nilai_tugas, nilai_uts, nilai_uas)
VALUES (
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500012'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TI301'),
    '2024/2025',
    85,
    90,
    88
);

INSERT INTO nilai (mahasiswa_id, matkul_id, tahun_ajaran, nilai_tugas, nilai_uts, nilai_uas)
VALUES (
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500012'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TI302'),
    '2024/2025',
    70,
    75,
    78
);

INSERT INTO nilai (mahasiswa_id, matkul_id, tahun_ajaran, nilai_tugas, nilai_uts, nilai_uas)
VALUES (
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500012'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TI305'),
    '2024/2025',
    90,
    92,
    95
);

INSERT INTO nilai (mahasiswa_id, matkul_id, tahun_ajaran, nilai_tugas, nilai_uts, nilai_uas)
VALUES (
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500013'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TI301'),
    '2024/2025',
    80,
    82,
    85
);

COMMIT;
