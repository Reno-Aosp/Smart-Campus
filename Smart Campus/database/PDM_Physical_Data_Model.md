# Physical Data Model (PDM) - Smart Campus Oracle Database

## Overview
The Physical Data Model represents the actual database implementation in Oracle, including tables, columns, data types, constraints, indexes, and sequences.

## Database Tables Specification

### 1. USERS
**Purpose**: Stores authentication and user account information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| user_id | NUMBER | PRIMARY KEY | Auto-generated user identifier |
| username | VARCHAR2(50) | UNIQUE NOT NULL | Login username |
| password | VARCHAR2(255) | NOT NULL | Encrypted password |
| email | VARCHAR2(100) | UNIQUE NOT NULL | User email address |
| role | VARCHAR2(20) | NOT NULL CHECK | User role (admin/dosen/mahasiswa) |
| is_active | NUMBER(1) | DEFAULT 1 CHECK | Active status (0=inactive, 1=active) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |
| last_login | TIMESTAMP | NULL | Last successful login time |

**Indexes**:
- `idx_users_role` on `role`
- `idx_users_email` on `email`

**Sequence**: `seq_user_id`

---

### 2. PROGRAM_STUDI
**Purpose**: Stores academic program/major information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| prodi_id | NUMBER | PRIMARY KEY | Auto-generated program identifier |
| kode_prodi | VARCHAR2(10) | UNIQUE NOT NULL | Program code (e.g., TI, SI) |
| nama_prodi | VARCHAR2(100) | NOT NULL | Program name |
| jenjang | VARCHAR2(20) | DEFAULT 'D3' CHECK | Education level (D3/D4/S1/S2) |
| fakultas | VARCHAR2(100) | NULL | Faculty name |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Sequence**: `seq_prodi_id`

---

### 3. DOSEN
**Purpose**: Stores lecturer/faculty information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| dosen_id | NUMBER | PRIMARY KEY | Auto-generated lecturer identifier |
| user_id | NUMBER | UNIQUE NOT NULL FK | Foreign key to users table |
| nip | VARCHAR2(20) | UNIQUE NOT NULL | National lecturer ID |
| nama_lengkap | VARCHAR2(100) | NOT NULL | Full name |
| gelar_depan | VARCHAR2(20) | NULL | Academic title prefix (Dr., Prof., etc.) |
| gelar_belakang | VARCHAR2(20) | NULL | Academic title suffix (M.Kom, Ph.D, etc.) |
| email | VARCHAR2(100) | NOT NULL | Email address |
| no_telepon | VARCHAR2(20) | NULL | Phone number |
| alamat | VARCHAR2(255) | NULL | Address |
| tanggal_lahir | DATE | NULL | Date of birth |
| jenis_kelamin | VARCHAR2(10) | CHECK | Gender (L/P) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `fk_dosen_user`: `user_id` → `users(user_id)` ON DELETE CASCADE

**Indexes**:
- `idx_dosen_nip` on `nip`

**Sequence**: `seq_dosen_id`

---

### 4. MAHASISWA
**Purpose**: Stores student information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| mahasiswa_id | NUMBER | PRIMARY KEY | Auto-generated student identifier |
| user_id | NUMBER | UNIQUE NOT NULL FK | Foreign key to users table |
| nim | VARCHAR2(20) | UNIQUE NOT NULL | Student ID number |
| nama_lengkap | VARCHAR2(100) | NOT NULL | Full name |
| prodi_id | NUMBER | NOT NULL FK | Foreign key to program_studi |
| email | VARCHAR2(100) | NOT NULL | Email address |
| no_telepon | VARCHAR2(20) | NULL | Phone number |
| alamat | VARCHAR2(255) | NULL | Address |
| tanggal_lahir | DATE | NULL | Date of birth |
| jenis_kelamin | VARCHAR2(10) | CHECK | Gender (L/P) |
| angkatan | NUMBER(4) | NULL | Enrollment year |
| semester | NUMBER(2) | DEFAULT 1 | Current semester |
| status | VARCHAR2(20) | DEFAULT 'Aktif' CHECK | Status (Aktif/Cuti/Lulus/DO) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `fk_mahasiswa_user`: `user_id` → `users(user_id)` ON DELETE CASCADE
- `fk_mahasiswa_prodi`: `prodi_id` → `program_studi(prodi_id)`

**Indexes**:
- `idx_mahasiswa_nim` on `nim`
- `idx_mahasiswa_prodi` on `prodi_id`

**Sequence**: `seq_mahasiswa_id`

---

### 5. KELAS
**Purpose**: Stores class/group information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| kelas_id | NUMBER | PRIMARY KEY | Auto-generated class identifier |
| kode_kelas | VARCHAR2(20) | UNIQUE NOT NULL | Class code (e.g., TI-3A) |
| nama_kelas | VARCHAR2(50) | NOT NULL | Class name |
| prodi_id | NUMBER | NOT NULL FK | Foreign key to program_studi |
| semester | NUMBER(2) | NOT NULL | Semester level |
| tahun_ajaran | VARCHAR2(20) | NOT NULL | Academic year (YYYY/YYYY) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `fk_kelas_prodi`: `prodi_id` → `program_studi(prodi_id)`

**Sequence**: `seq_kelas_id`

---

### 6. MATA_KULIAH
**Purpose**: Stores course/subject information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| matkul_id | NUMBER | PRIMARY KEY | Auto-generated course identifier |
| kode_matkul | VARCHAR2(20) | UNIQUE NOT NULL | Course code |
| nama_matkul | VARCHAR2(100) | NOT NULL | Course name |
| sks | NUMBER(2) | NOT NULL CHECK | Credit hours (must be > 0) |
| semester | NUMBER(2) | NOT NULL | Recommended semester |
| prodi_id | NUMBER | NOT NULL FK | Foreign key to program_studi |
| dosen_id | NUMBER | NULL FK | Foreign key to dosen |
| jenis_matkul | VARCHAR2(20) | DEFAULT 'Wajib' CHECK | Course type (Wajib/Pilihan) |
| deskripsi | CLOB | NULL | Course description |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `fk_matkul_prodi`: `prodi_id` → `program_studi(prodi_id)`
- `fk_matkul_dosen`: `dosen_id` → `dosen(dosen_id)` ON DELETE SET NULL

**Indexes**:
- `idx_matkul_dosen` on `dosen_id`

**Sequence**: `seq_matkul_id`

---

### 7. KELAS_MAHASISWA
**Purpose**: Junction table for student enrollment in classes

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| kelas_mahasiswa_id | NUMBER | PRIMARY KEY | Auto-generated enrollment identifier |
| kelas_id | NUMBER | NOT NULL FK | Foreign key to kelas |
| mahasiswa_id | NUMBER | NOT NULL FK | Foreign key to mahasiswa |
| tahun_ajaran | VARCHAR2(20) | NOT NULL | Academic year |
| status | VARCHAR2(20) | DEFAULT 'Aktif' CHECK | Enrollment status |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Foreign Keys**:
- `fk_km_kelas`: `kelas_id` → `kelas(kelas_id)` ON DELETE CASCADE
- `fk_km_mahasiswa`: `mahasiswa_id` → `mahasiswa(mahasiswa_id)` ON DELETE CASCADE

**Unique Constraints**:
- `uk_kelas_mahasiswa`: UNIQUE(`kelas_id`, `mahasiswa_id`, `tahun_ajaran`)

**Sequence**: `seq_kelas_id` (reused - should be separate sequence)

---

### 8. JADWAL_KULIAH
**Purpose**: Stores course schedules

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| jadwal_id | NUMBER | PRIMARY KEY | Auto-generated schedule identifier |
| kelas_id | NUMBER | NOT NULL FK | Foreign key to kelas |
| matkul_id | NUMBER | NOT NULL FK | Foreign key to mata_kuliah |
| dosen_id | NUMBER | NOT NULL FK | Foreign key to dosen |
| hari | VARCHAR2(20) | NOT NULL CHECK | Day of week |
| jam_mulai | VARCHAR2(10) | NOT NULL | Start time (HH:MM) |
| jam_selesai | VARCHAR2(10) | NOT NULL | End time (HH:MM) |
| ruangan | VARCHAR2(50) | NOT NULL | Room/location |
| tahun_ajaran | VARCHAR2(20) | NOT NULL | Academic year |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `fk_jadwal_kelas`: `kelas_id` → `kelas(kelas_id)` ON DELETE CASCADE
- `fk_jadwal_matkul`: `matkul_id` → `mata_kuliah(matkul_id)` ON DELETE CASCADE
- `fk_jadwal_dosen`: `dosen_id` → `dosen(dosen_id)`

**Check Constraints**:
- `hari` IN ('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu')

**Indexes**:
- `idx_jadwal_hari` on `hari`

**Sequence**: `seq_jadwal_id`

---

### 9. ABSENSI
**Purpose**: Stores student attendance records

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| absensi_id | NUMBER | PRIMARY KEY | Auto-generated attendance identifier |
| jadwal_id | NUMBER | NOT NULL FK | Foreign key to jadwal_kuliah |
| mahasiswa_id | NUMBER | NOT NULL FK | Foreign key to mahasiswa |
| tanggal | DATE | NOT NULL | Attendance date |
| status_kehadiran | VARCHAR2(20) | DEFAULT 'Hadir' CHECK | Attendance status |
| keterangan | VARCHAR2(255) | NULL | Notes/remarks |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `fk_absensi_jadwal`: `jadwal_id` → `jadwal_kuliah(jadwal_id)` ON DELETE CASCADE
- `fk_absensi_mahasiswa`: `mahasiswa_id` → `mahasiswa(mahasiswa_id)` ON DELETE CASCADE

**Check Constraints**:
- `status_kehadiran` IN ('Hadir', 'Izin', 'Sakit', 'Alpa')

**Unique Constraints**:
- `uk_absensi`: UNIQUE(`jadwal_id`, `mahasiswa_id`, `tanggal`)

**Indexes**:
- `idx_absensi_tanggal` on `tanggal`

**Sequence**: `seq_absensi_id`

---

### 10. NILAI
**Purpose**: Stores student grades

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| nilai_id | NUMBER | PRIMARY KEY | Auto-generated grade identifier |
| mahasiswa_id | NUMBER | NOT NULL FK | Foreign key to mahasiswa |
| matkul_id | NUMBER | NOT NULL FK | Foreign key to mata_kuliah |
| tahun_ajaran | VARCHAR2(20) | NOT NULL | Academic year |
| nilai_tugas | NUMBER(5,2) | DEFAULT 0 CHECK | Assignment grade (0-100) |
| nilai_uts | NUMBER(5,2) | DEFAULT 0 CHECK | Midterm exam grade (0-100) |
| nilai_uas | NUMBER(5,2) | DEFAULT 0 CHECK | Final exam grade (0-100) |
| nilai_akhir | NUMBER(5,2) | DEFAULT 0 CHECK | Final grade (auto-calculated) |
| grade | VARCHAR2(2) | NULL | Letter grade (A/B/C/D/E) |
| status | VARCHAR2(20) | DEFAULT 'Belum Lulus' CHECK | Pass status |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `fk_nilai_mahasiswa`: `mahasiswa_id` → `mahasiswa(mahasiswa_id)` ON DELETE CASCADE
- `fk_nilai_matkul`: `matkul_id` → `mata_kuliah(matkul_id)` ON DELETE CASCADE

**Check Constraints**:
- `nilai_tugas` BETWEEN 0 AND 100
- `nilai_uts` BETWEEN 0 AND 100
- `nilai_uas` BETWEEN 0 AND 100
- `nilai_akhir` BETWEEN 0 AND 100
- `status` IN ('Lulus', 'Belum Lulus', 'Mengulang')

**Unique Constraints**:
- `uk_nilai`: UNIQUE(`mahasiswa_id`, `matkul_id`, `tahun_ajaran`)

**Indexes**:
- `idx_nilai_tahun` on `tahun_ajaran`

**Sequence**: `seq_nilai_id`

---

## Database Triggers

### Auto-Increment Triggers
Each table has BEFORE INSERT triggers to populate primary keys from sequences:
- `trg_users_bi`, `trg_prodi_bi`, `trg_dosen_bi`, `trg_mahasiswa_bi`, `trg_kelas_bi`
- `trg_matkul_bi`, `trg_jadwal_bi`, `trg_absensi_bi`, `trg_nilai_bi`

### Timestamp Update Triggers
Each table has BEFORE UPDATE triggers to update `updated_at`:
- `trg_users_bu`, `trg_prodi_bu`, `trg_dosen_bu`, `trg_mahasiswa_bu`, `trg_kelas_bu`
- `trg_matkul_bu`, `trg_jadwal_bu`, `trg_absensi_bu`, `trg_nilai_bu`

### Business Logic Triggers

**trg_nilai_bi / trg_nilai_bu**:
- Auto-calculates `nilai_akhir` = (nilai_tugas × 0.3) + (nilai_uts × 0.3) + (nilai_uas × 0.4)
- Auto-assigns `grade` based on nilai_akhir:
  - A: ≥ 85
  - B: ≥ 75
  - C: ≥ 65
  - D: ≥ 55
  - E: < 55
- Auto-sets `status` = 'Lulus' for grades A, B, C

---

## Stored Procedures

| Procedure Name | Parameters | Description |
|---------------|------------|-------------|
| sp_add_mahasiswa | 10 parameters | Add new student with user account |
| sp_add_dosen | 9 parameters | Add new lecturer with user account |
| sp_record_absensi | 5 parameters | Record/update attendance |
| sp_input_nilai | 6 parameters | Input/update grades |

---

## Functions

| Function Name | Parameters | Returns | Description |
|--------------|------------|---------|-------------|
| fn_calculate_ipk | p_nim | NUMBER | Calculate student GPA |
| fn_get_attendance_percentage | p_nim, p_kode_matkul, p_tahun_ajaran | NUMBER | Get attendance percentage |

---

## Views

| View Name | Description |
|-----------|-------------|
| vw_student_dashboard | Student overview with program and class info |
| vw_lecturer_dashboard | Lecturer overview with course statistics |
| vw_student_grades | Complete student grades report |
| vw_attendance_report | Detailed attendance records |
| vw_jadwal_lengkap | Complete course schedule with all details |

---

## Storage Specifications

### Recommended Tablespace Settings
- **System Tablespace**: SYSTEM (for data dictionary)
- **User Tablespace**: USERS (for application data)
- **Temp Tablespace**: TEMP (for sorting operations)
- **Undo Tablespace**: UNDOTBS1 (for rollback)

### Table Storage Parameters
```sql
STORAGE (
  INITIAL 64K
  NEXT 64K
  MINEXTENTS 1
  MAXEXTENTS UNLIMITED
  PCTINCREASE 0
)
```

---

## Performance Optimization

### Indexing Strategy
- Primary key indexes (automatic)
- Foreign key indexes (for join performance)
- Frequently searched columns (NIM, NIP, email, role)
- Date columns for reporting (tanggal, tahun_ajaran)

### Partitioning Recommendations
For large datasets, consider partitioning:
- **ABSENSI**: Range partition by `tanggal` (yearly)
- **NILAI**: List partition by `tahun_ajaran`

### Statistics Collection
```sql
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SMARTCAMPUS');
```

---

## Security Measures

### Password Storage
- Passwords should be hashed using DBMS_CRYPTO or bcrypt
- Current schema stores plain text (development only)

### Access Control
- Create separate roles: `ROLE_ADMIN`, `ROLE_DOSEN`, `ROLE_MAHASISWA`
- Grant appropriate privileges per role
- Use VPD (Virtual Private Database) for row-level security

### Audit Trail
- All tables include `created_at` and `updated_at`
- Consider enabling Oracle auditing for sensitive operations

---

## Backup Strategy

### Full Backup
```bash
expdp username/password schemas=SMARTCAMPUS directory=DATA_PUMP_DIR dumpfile=smartcampus_full.dmp
```

### Incremental Backup
- Daily: Export changed data
- Weekly: Full schema export
- Monthly: Full database backup

---

## Data Volume Estimates

| Table | Estimated Rows | Growth Rate |
|-------|---------------|-------------|
| users | 10,000 | 1,000/year |
| mahasiswa | 5,000 | 800/year |
| dosen | 200 | 20/year |
| program_studi | 20 | 2/year |
| mata_kuliah | 500 | 50/year |
| kelas | 200 | 40/year |
| jadwal_kuliah | 1,000 | 200/year |
| absensi | 500,000 | 100,000/year |
| nilai | 50,000 | 10,000/year |

---

## Database Maintenance Tasks

### Daily
- Monitor alert logs
- Check tablespace usage

### Weekly
- Gather statistics
- Check invalid objects
- Review slow queries

### Monthly
- Full backup
- Rebuild fragmented indexes
- Archive old data

---

**Version**: 1.0  
**Last Updated**: November 2025  
**Database Platform**: Oracle 11g/12c/19c+  
**Character Set**: AL32UTF8
