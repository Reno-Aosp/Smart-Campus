-- =====================================================
-- SAMPLE DATA FOR SMART CAMPUS DATABASE (UPDATED)
-- =====================================================

-- =====================================================
-- INSERT USERS
-- =====================================================

-- Admin
INSERT INTO users (username, password, email, role, is_active)
VALUES ('admin', 'admin123', 'admin@smartcampus.ac.id', 'admin', 1);

-- Dosen
INSERT INTO users (username, password, email, role, is_active)
VALUES ('Frizzki', 'dosen123', 'frizzki@gmail.com', 'dosen', 1);

INSERT INTO users (username, password, email, role, is_active)
VALUES ('Zuhriansyah', 'dosen123', 'zuhra@gmail.com', 'dosen', 1);

-- Mahasiswa
INSERT INTO users (username, password, email, role, is_active)
VALUES ('Zuhri', 'mhs123', 'zuhri@gmail.com', 'mahasiswa', 1);

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

INSERT INTO dosen (user_id, nip, nama_lengkap, email, no_telepon, jenis_kelamin)
VALUES (
    (SELECT user_id FROM users WHERE username = 'Frizzki'),
    '312300032',
    'Frizzki',
    'frizzki@gmail.com',
    '081234567801',
    'L'
);

INSERT INTO dosen (user_id, nip, nama_lengkap, email, no_telepon, jenis_kelamin)
VALUES (
    (SELECT user_id FROM users WHERE username = 'Zuhriansyah'),
    '312300033',
    'Zuhriansyah',
    'zuhra@gmail.com',
    '081234567802',
    'L'
);

-- =====================================================
-- INSERT MAHASISWA
-- =====================================================

INSERT INTO mahasiswa (user_id, nim, nama_lengkap, prodi_id, email, no_telepon, jenis_kelamin, angkatan, semester, status)
VALUES (
    (SELECT user_id FROM users WHERE username = 'Zuhri'),
    '3122500014',
    'Zuhri',
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TK'),
    'zuhri@gmail.com',
    '081234567803',
    'L',
    2022,
    5,
    'Aktif'
);

-- =====================================================
-- INSERT KELAS
-- =====================================================

INSERT INTO kelas (kode_kelas, nama_kelas, prodi_id, semester, tahun_ajaran)
VALUES (
    'TK-3A',
    'TK-3A',
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TK'),
    5,
    '2024/2025'
);

INSERT INTO kelas (kode_kelas, nama_kelas, prodi_id, semester, tahun_ajaran)
VALUES (
    'TK-3B',
    'TK-3B',
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TK'),
    5,
    '2024/2025'
);

-- =====================================================
-- INSERT MATA KULIAH
-- =====================================================

INSERT INTO mata_kuliah (kode_matkul, nama_matkul, sks, semester, prodi_id, dosen_id, jenis_matkul)
VALUES (
    'TK301',
    'WABW',
    3,
    5,
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TK'),
    (SELECT dosen_id FROM dosen WHERE nip = '312300032'),
    'Wajib'
);

INSERT INTO mata_kuliah (kode_matkul, nama_matkul, sks, semester, prodi_id, dosen_id, jenis_matkul)
VALUES (
    'TK302',
    'Basis Data Lanjut',
    3,
    5,
    (SELECT prodi_id FROM program_studi WHERE kode_prodi = 'TK'),
    (SELECT dosen_id FROM dosen WHERE nip = '312300033'),
    'Wajib'
);

-- =====================================================
-- INSERT KELAS_MAHASISWA
-- =====================================================

INSERT INTO kelas_mahasiswa (kelas_id, mahasiswa_id, tahun_ajaran, status)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TK-3B'),
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500014'),
    '2024/2025',
    'Aktif'
);

-- =====================================================
-- INSERT JADWAL KULIAH
-- =====================================================

INSERT INTO jadwal_kuliah (kelas_id, matkul_id, dosen_id, hari, jam_mulai, jam_selesai, ruangan, tahun_ajaran)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TK-3B'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TK301'),
    (SELECT dosen_id FROM dosen WHERE nip = '312300032'),
    'Senin',
    '08:00',
    '09:40',
    'D201',
    '2024/2025'
);

INSERT INTO jadwal_kuliah (kelas_id, matkul_id, dosen_id, hari, jam_mulai, jam_selesai, ruangan, tahun_ajaran)
VALUES (
    (SELECT kelas_id FROM kelas WHERE kode_kelas = 'TK-3B'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TK302'),
    (SELECT dosen_id FROM dosen WHERE nip = '312300033'),
    'Selasa',
    '10:00',
    '11:40',
    'D202',
    '2024/2025'
);

-- =====================================================
-- INSERT ABSENSI
-- =====================================================

INSERT INTO absensi (jadwal_id, mahasiswa_id, tanggal, status_kehadiran, keterangan)
VALUES (
    1,
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500014'),
    TO_DATE('2024-11-04', 'YYYY-MM-DD'),
    'Hadir',
    NULL
);

INSERT INTO absensi (jadwal_id, mahasiswa_id, tanggal, status_kehadiran, keterangan)
VALUES (
    2,
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500014'),
    TO_DATE('2024-10-28', 'YYYY-MM-DD'),
    'Hadir',
    NULL
);

-- =====================================================
-- INSERT NILAI
-- =====================================================

INSERT INTO nilai (mahasiswa_id, matkul_id, tahun_ajaran, nilai_tugas, nilai_uts, nilai_uas)
VALUES (
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500014'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TK301'),
    '2024/2025',
    85,
    90,
    88
);

INSERT INTO nilai (mahasiswa_id, matkul_id, tahun_ajaran, nilai_tugas, nilai_uts, nilai_uas)
VALUES (
    (SELECT mahasiswa_id FROM mahasiswa WHERE nim = '3122500014'),
    (SELECT matkul_id FROM mata_kuliah WHERE kode_matkul = 'TK302'),
    '2024/2025',
    82,
    86,
    89
);

COMMIT;
