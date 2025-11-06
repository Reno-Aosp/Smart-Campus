-- 1) Buat user UAS2
CREATE USER uas2 IDENTIFIED BY uas2
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- 2) Beri hak akses penting
GRANT CREATE SESSION TO uas2;
GRANT CREATE TABLE TO uas2;
GRANT CREATE VIEW TO uas2;
GRANT CREATE SEQUENCE TO uas2;
GRANT CREATE TRIGGER TO uas2;
GRANT CREATE PROCEDURE TO uas2;
GRANT CREATE TYPE TO uas2;
GRANT UNLIMITED TABLESPACE TO uas2;

-- 3) (Opsional) Ganti schema aktif ke uas2 jika jalankan sebagai SYS
ALTER SESSION SET CURRENT_SCHEMA = uas2;

-- =====================================================
-- 4️⃣ Drop table dan sequence lama bila ada
-- =====================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE nilai CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE absensi CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE jadwal_kuliah CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE kelas_mahasiswa CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE mata_kuliah CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE kelas CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE mahasiswa CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE dosen CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE program_studi CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_user_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_prodi_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_dosen_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_mahasiswa_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_kelas_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_matkul_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_jadwal_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_absensi_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_nilai_id';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- =====================================================
-- CREATE SEQUENCES
-- =====================================================

CREATE SEQUENCE seq_user_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_prodi_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_dosen_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_mahasiswa_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_kelas_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_matkul_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_jadwal_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_absensi_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_nilai_id START WITH 1 INCREMENT BY 1;

-- =====================================================
-- TABLE: USERS (Login Authentication)
-- =====================================================

CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) UNIQUE NOT NULL,
    password VARCHAR2(255) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    role VARCHAR2(20) NOT NULL CHECK (role IN ('admin', 'dosen', 'mahasiswa')),
    is_active NUMBER(1) DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- =====================================================
-- TABLE: PROGRAM_STUDI
-- =====================================================

CREATE TABLE program_studi (
    prodi_id NUMBER PRIMARY KEY,
    kode_prodi VARCHAR2(10) UNIQUE NOT NULL,
    nama_prodi VARCHAR2(100) NOT NULL,
    jenjang VARCHAR2(20) DEFAULT 'D3' CHECK (jenjang IN ('D3', 'D4', 'S1', 'S2')),
    fakultas VARCHAR2(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: DOSEN
-- =====================================================

CREATE TABLE dosen (
    dosen_id NUMBER PRIMARY KEY,
    user_id NUMBER UNIQUE NOT NULL,
    nip VARCHAR2(20) UNIQUE NOT NULL,
    nama_lengkap VARCHAR2(100) NOT NULL,
    gelar_depan VARCHAR2(20),
    gelar_belakang VARCHAR2(20),
    email VARCHAR2(100) NOT NULL,
    no_telepon VARCHAR2(20),
    alamat VARCHAR2(255),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR2(10) CHECK (jenis_kelamin IN ('L', 'P')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dosen_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- =====================================================
-- TABLE: MAHASISWA
-- =====================================================

CREATE TABLE mahasiswa (
    mahasiswa_id NUMBER PRIMARY KEY,
    user_id NUMBER UNIQUE NOT NULL,
    nim VARCHAR2(20) UNIQUE NOT NULL,
    nama_lengkap VARCHAR2(100) NOT NULL,
    prodi_id NUMBER NOT NULL,
    email VARCHAR2(100) NOT NULL,
    no_telepon VARCHAR2(20),
    alamat VARCHAR2(255),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR2(10) CHECK (jenis_kelamin IN ('L', 'P')),
    angkatan NUMBER(4),
    semester NUMBER(2) DEFAULT 1,
    status VARCHAR2(20) DEFAULT 'Aktif' CHECK (status IN ('Aktif', 'Cuti', 'Lulus', 'DO')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mahasiswa_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_mahasiswa_prodi FOREIGN KEY (prodi_id) REFERENCES program_studi(prodi_id)
);

-- =====================================================
-- TABLE: KELAS
-- =====================================================

CREATE TABLE kelas (
    kelas_id NUMBER PRIMARY KEY,
    kode_kelas VARCHAR2(20) UNIQUE NOT NULL,
    nama_kelas VARCHAR2(50) NOT NULL,
    prodi_id NUMBER NOT NULL,
    semester NUMBER(2) NOT NULL,
    tahun_ajaran VARCHAR2(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_kelas_prodi FOREIGN KEY (prodi_id) REFERENCES program_studi(prodi_id)
);

-- =====================================================
-- TABLE: MATA_KULIAH
-- =====================================================

CREATE TABLE mata_kuliah (
    matkul_id NUMBER PRIMARY KEY,
    kode_matkul VARCHAR2(20) UNIQUE NOT NULL,
    nama_matkul VARCHAR2(100) NOT NULL,
    sks NUMBER(2) NOT NULL CHECK (sks > 0),
    semester NUMBER(2) NOT NULL,
    prodi_id NUMBER NOT NULL,
    dosen_id NUMBER,
    jenis_matkul VARCHAR2(20) DEFAULT 'Wajib' CHECK (jenis_matkul IN ('Wajib', 'Pilihan')),
    deskripsi CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_matkul_prodi FOREIGN KEY (prodi_id) REFERENCES program_studi(prodi_id),
    CONSTRAINT fk_matkul_dosen FOREIGN KEY (dosen_id) REFERENCES dosen(dosen_id) ON DELETE SET NULL
);

-- =====================================================
-- TABLE: KELAS_MAHASISWA (Enrollment)
-- =====================================================

CREATE TABLE kelas_mahasiswa (
    kelas_mahasiswa_id NUMBER PRIMARY KEY,
    kelas_id NUMBER NOT NULL,
    mahasiswa_id NUMBER NOT NULL,
    tahun_ajaran VARCHAR2(20) NOT NULL,
    status VARCHAR2(20) DEFAULT 'Aktif' CHECK (status IN ('Aktif', 'Tidak Aktif')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_km_kelas FOREIGN KEY (kelas_id) REFERENCES kelas(kelas_id) ON DELETE CASCADE,
    CONSTRAINT fk_km_mahasiswa FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(mahasiswa_id) ON DELETE CASCADE,
    CONSTRAINT uk_kelas_mahasiswa UNIQUE (kelas_id, mahasiswa_id, tahun_ajaran)
);

-- =====================================================
-- TABLE: JADWAL_KULIAH
-- =====================================================

CREATE TABLE jadwal_kuliah (
    jadwal_id NUMBER PRIMARY KEY,
    kelas_id NUMBER NOT NULL,
    matkul_id NUMBER NOT NULL,
    dosen_id NUMBER NOT NULL,
    hari VARCHAR2(20) NOT NULL CHECK (hari IN ('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu')),
    jam_mulai VARCHAR2(10) NOT NULL,
    jam_selesai VARCHAR2(10) NOT NULL,
    ruangan VARCHAR2(50) NOT NULL,
    tahun_ajaran VARCHAR2(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_jadwal_kelas FOREIGN KEY (kelas_id) REFERENCES kelas(kelas_id) ON DELETE CASCADE,
    CONSTRAINT fk_jadwal_matkul FOREIGN KEY (matkul_id) REFERENCES mata_kuliah(matkul_id) ON DELETE CASCADE,
    CONSTRAINT fk_jadwal_dosen FOREIGN KEY (dosen_id) REFERENCES dosen(dosen_id)
);

-- =====================================================
-- TABLE: ABSENSI
-- =====================================================

CREATE TABLE absensi (
    absensi_id NUMBER PRIMARY KEY,
    jadwal_id NUMBER NOT NULL,
    mahasiswa_id NUMBER NOT NULL,
    tanggal DATE NOT NULL,
    status_kehadiran VARCHAR2(20) DEFAULT 'Hadir' CHECK (status_kehadiran IN ('Hadir', 'Izin', 'Sakit', 'Alpa')),
    keterangan VARCHAR2(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_absensi_jadwal FOREIGN KEY (jadwal_id) REFERENCES jadwal_kuliah(jadwal_id) ON DELETE CASCADE,
    CONSTRAINT fk_absensi_mahasiswa FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(mahasiswa_id) ON DELETE CASCADE,
    CONSTRAINT uk_absensi UNIQUE (jadwal_id, mahasiswa_id, tanggal)
);

-- =====================================================
-- TABLE: NILAI
-- =====================================================

CREATE TABLE nilai (
    nilai_id NUMBER PRIMARY KEY,
    mahasiswa_id NUMBER NOT NULL,
    matkul_id NUMBER NOT NULL,
    tahun_ajaran VARCHAR2(20) NOT NULL,
    nilai_tugas NUMBER(5,2) DEFAULT 0 CHECK (nilai_tugas >= 0 AND nilai_tugas <= 100),
    nilai_uts NUMBER(5,2) DEFAULT 0 CHECK (nilai_uts >= 0 AND nilai_uts <= 100),
    nilai_uas NUMBER(5,2) DEFAULT 0 CHECK (nilai_uas >= 0 AND nilai_uas <= 100),
    nilai_akhir NUMBER(5,2) DEFAULT 0 CHECK (nilai_akhir >= 0 AND nilai_akhir <= 100),
    grade VARCHAR2(2),
    status VARCHAR2(20) DEFAULT 'Belum Lulus' CHECK (status IN ('Lulus', 'Belum Lulus', 'Mengulang')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nilai_mahasiswa FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(mahasiswa_id) ON DELETE CASCADE,
    CONSTRAINT fk_nilai_matkul FOREIGN KEY (matkul_id) REFERENCES mata_kuliah(matkul_id) ON DELETE CASCADE,
    CONSTRAINT uk_nilai UNIQUE (mahasiswa_id, matkul_id, tahun_ajaran)
);

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_dosen_nip ON dosen(nip);
CREATE INDEX idx_mahasiswa_nim ON mahasiswa(nim);
CREATE INDEX idx_mahasiswa_prodi ON mahasiswa(prodi_id);
CREATE INDEX idx_matkul_dosen ON mata_kuliah(dosen_id);
CREATE INDEX idx_jadwal_hari ON jadwal_kuliah(hari);
CREATE INDEX idx_absensi_tanggal ON absensi(tanggal);
CREATE INDEX idx_nilai_tahun ON nilai(tahun_ajaran);

-- =====================================================
-- TRIGGERS FOR AUTO-INCREMENT AND TIMESTAMPS
-- =====================================================

-- Trigger for users table
CREATE OR REPLACE TRIGGER trg_users_bi
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        SELECT seq_user_id.NEXTVAL INTO :NEW.user_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_users_bu
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for program_studi table
CREATE OR REPLACE TRIGGER trg_prodi_bi
BEFORE INSERT ON program_studi
FOR EACH ROW
BEGIN
    IF :NEW.prodi_id IS NULL THEN
        SELECT seq_prodi_id.NEXTVAL INTO :NEW.prodi_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_prodi_bu
BEFORE UPDATE ON program_studi
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for dosen table
CREATE OR REPLACE TRIGGER trg_dosen_bi
BEFORE INSERT ON dosen
FOR EACH ROW
BEGIN
    IF :NEW.dosen_id IS NULL THEN
        SELECT seq_dosen_id.NEXTVAL INTO :NEW.dosen_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_dosen_bu
BEFORE UPDATE ON dosen
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for mahasiswa table
CREATE OR REPLACE TRIGGER trg_mahasiswa_bi
BEFORE INSERT ON mahasiswa
FOR EACH ROW
BEGIN
    IF :NEW.mahasiswa_id IS NULL THEN
        SELECT seq_mahasiswa_id.NEXTVAL INTO :NEW.mahasiswa_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_mahasiswa_bu
BEFORE UPDATE ON mahasiswa
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for kelas table
CREATE OR REPLACE TRIGGER trg_kelas_bi
BEFORE INSERT ON kelas
FOR EACH ROW
BEGIN
    IF :NEW.kelas_id IS NULL THEN
        SELECT seq_kelas_id.NEXTVAL INTO :NEW.kelas_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_kelas_bu
BEFORE UPDATE ON kelas
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for mata_kuliah table
CREATE OR REPLACE TRIGGER trg_matkul_bi
BEFORE INSERT ON mata_kuliah
FOR EACH ROW
BEGIN
    IF :NEW.matkul_id IS NULL THEN
        SELECT seq_matkul_id.NEXTVAL INTO :NEW.matkul_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_matkul_bu
BEFORE UPDATE ON mata_kuliah
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for jadwal_kuliah table
CREATE OR REPLACE TRIGGER trg_jadwal_bi
BEFORE INSERT ON jadwal_kuliah
FOR EACH ROW
BEGIN
    IF :NEW.jadwal_id IS NULL THEN
        SELECT seq_jadwal_id.NEXTVAL INTO :NEW.jadwal_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_jadwal_bu
BEFORE UPDATE ON jadwal_kuliah
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for absensi table
CREATE OR REPLACE TRIGGER trg_absensi_bi
BEFORE INSERT ON absensi
FOR EACH ROW
BEGIN
    IF :NEW.absensi_id IS NULL THEN
        SELECT seq_absensi_id.NEXTVAL INTO :NEW.absensi_id FROM dual;
    END IF;
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_absensi_bu
BEFORE UPDATE ON absensi
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Trigger for nilai table - Auto calculate grade
CREATE OR REPLACE TRIGGER trg_nilai_bi
BEFORE INSERT ON nilai
FOR EACH ROW
DECLARE
    v_grade VARCHAR2(2);
BEGIN
    IF :NEW.nilai_id IS NULL THEN
        SELECT seq_nilai_id.NEXTVAL INTO :NEW.nilai_id FROM dual;
    END IF;
    
    -- Calculate nilai_akhir (30% Tugas + 30% UTS + 40% UAS)
    :NEW.nilai_akhir := (:NEW.nilai_tugas * 0.3) + (:NEW.nilai_uts * 0.3) + (:NEW.nilai_uas * 0.4);
    
    -- Determine grade based on nilai_akhir
    IF :NEW.nilai_akhir >= 85 THEN
        v_grade := 'A';
    ELSIF :NEW.nilai_akhir >= 75 THEN
        v_grade := 'B';
    ELSIF :NEW.nilai_akhir >= 65 THEN
        v_grade := 'C';
    ELSIF :NEW.nilai_akhir >= 55 THEN
        v_grade := 'D';
    ELSE
        v_grade := 'E';
    END IF;
    
    :NEW.grade := v_grade;
    
    -- Set status based on grade
    IF v_grade IN ('A', 'B', 'C') THEN
        :NEW.status := 'Lulus';
    ELSE
        :NEW.status := 'Belum Lulus';
    END IF;
    
    :NEW.created_at := CURRENT_TIMESTAMP;
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_nilai_bu
BEFORE UPDATE ON nilai
FOR EACH ROW
DECLARE
    v_grade VARCHAR2(2);
BEGIN
    -- Recalculate nilai_akhir
    :NEW.nilai_akhir := (:NEW.nilai_tugas * 0.3) + (:NEW.nilai_uts * 0.3) + (:NEW.nilai_uas * 0.4);
    
    -- Determine grade
    IF :NEW.nilai_akhir >= 85 THEN
        v_grade := 'A';
    ELSIF :NEW.nilai_akhir >= 75 THEN
        v_grade := 'B';
    ELSIF :NEW.nilai_akhir >= 65 THEN
        v_grade := 'C';
    ELSIF :NEW.nilai_akhir >= 55 THEN
        v_grade := 'D';
    ELSE
        v_grade := 'E';
    END IF;
    
    :NEW.grade := v_grade;
    
    -- Update status
    IF v_grade IN ('A', 'B', 'C') THEN
        :NEW.status := 'Lulus';
    ELSE
        :NEW.status := 'Belum Lulus';
    END IF;
    
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

COMMIT;