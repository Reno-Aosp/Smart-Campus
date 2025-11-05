# Smart Campus - Oracle Database Documentation

## Overview
This database is designed for a Smart Campus Management System using Oracle Database. It manages students, lecturers, courses, schedules, attendance, and grades.

## Database Structure

### Core Tables

#### 1. **users**
Stores authentication information for all system users.
- **Primary Key**: `user_id`
- **Columns**:
  - `username` - Unique login username
  - `password` - User password (should be encrypted in production)
  - `email` - User email address
  - `role` - User role (admin, dosen, mahasiswa)
  - `is_active` - Account status (0=inactive, 1=active)
  - `last_login` - Last login timestamp

#### 2. **program_studi**
Stores academic programs/majors.
- **Primary Key**: `prodi_id`
- **Columns**:
  - `kode_prodi` - Program code (e.g., TI, SI)
  - `nama_prodi` - Program name
  - `jenjang` - Education level (D3, D4, S1, S2)
  - `fakultas` - Faculty name

#### 3. **dosen** (Lecturers)
Stores lecturer information.
- **Primary Key**: `dosen_id`
- **Foreign Keys**: `user_id` → users
- **Columns**:
  - `nip` - National Lecturer ID
  - `nama_lengkap` - Full name
  - `gelar_depan` - Academic title (prefix)
  - `gelar_belakang` - Academic title (suffix)
  - `email`, `no_telepon`, `alamat`
  - `jenis_kelamin` - Gender (L/P)

#### 4. **mahasiswa** (Students)
Stores student information.
- **Primary Key**: `mahasiswa_id`
- **Foreign Keys**: 
  - `user_id` → users
  - `prodi_id` → program_studi
- **Columns**:
  - `nim` - Student ID Number
  - `nama_lengkap` - Full name
  - `angkatan` - Year of enrollment
  - `semester` - Current semester
  - `status` - Student status (Aktif, Cuti, Lulus, DO)

#### 5. **kelas** (Classes)
Stores class information.
- **Primary Key**: `kelas_id`
- **Foreign Keys**: `prodi_id` → program_studi
- **Columns**:
  - `kode_kelas` - Class code (e.g., TI-3A)
  - `nama_kelas` - Class name
  - `semester` - Semester level
  - `tahun_ajaran` - Academic year

#### 6. **mata_kuliah** (Courses)
Stores course/subject information.
- **Primary Key**: `matkul_id`
- **Foreign Keys**: 
  - `prodi_id` → program_studi
  - `dosen_id` → dosen
- **Columns**:
  - `kode_matkul` - Course code
  - `nama_matkul` - Course name
  - `sks` - Credit hours
  - `semester` - Recommended semester
  - `jenis_matkul` - Course type (Wajib/Pilihan)

#### 7. **kelas_mahasiswa** (Enrollment)
Maps students to classes.
- **Primary Key**: `kelas_mahasiswa_id`
- **Foreign Keys**: 
  - `kelas_id` → kelas
  - `mahasiswa_id` → mahasiswa

#### 8. **jadwal_kuliah** (Schedule)
Stores course schedules.
- **Primary Key**: `jadwal_id`
- **Foreign Keys**: 
  - `kelas_id` → kelas
  - `matkul_id` → mata_kuliah
  - `dosen_id` → dosen
- **Columns**:
  - `hari` - Day of week
  - `jam_mulai` - Start time
  - `jam_selesai` - End time
  - `ruangan` - Room number
  - `tahun_ajaran` - Academic year

#### 9. **absensi** (Attendance)
Records student attendance.
- **Primary Key**: `absensi_id`
- **Foreign Keys**: 
  - `jadwal_id` → jadwal_kuliah
  - `mahasiswa_id` → mahasiswa
- **Columns**:
  - `tanggal` - Attendance date
  - `status_kehadiran` - Status (Hadir, Izin, Sakit, Alpa)
  - `keterangan` - Notes

#### 10. **nilai** (Grades)
Stores student grades.
- **Primary Key**: `nilai_id`
- **Foreign Keys**: 
  - `mahasiswa_id` → mahasiswa
  - `matkul_id` → mata_kuliah
- **Columns**:
  - `nilai_tugas` - Assignment grade (0-100)
  - `nilai_uts` - Midterm exam grade
  - `nilai_uas` - Final exam grade
  - `nilai_akhir` - Final grade (auto-calculated)
  - `grade` - Letter grade (A, B, C, D, E)
  - `status` - Pass status

### Grade Calculation Formula
```
nilai_akhir = (nilai_tugas × 30%) + (nilai_uts × 30%) + (nilai_uas × 40%)
```

### Grading Scale
- **A**: nilai_akhir ≥ 85
- **B**: nilai_akhir ≥ 75
- **C**: nilai_akhir ≥ 65
- **D**: nilai_akhir ≥ 55
- **E**: nilai_akhir < 55

## Stored Procedures

### 1. `sp_add_mahasiswa`
Adds a new student with user account.

**Parameters:**
```sql
p_username, p_password, p_nim, p_nama_lengkap, p_prodi_kode,
p_email, p_no_telepon, p_jenis_kelamin, p_angkatan, p_semester
```

**Example:**
```sql
EXEC sp_add_mahasiswa('3122500014', 'mhs123', '3122500014', 
    'John Doe', 'TI', 'john@example.com', '081234567894', 
    'L', 2022, 5);
```

### 2. `sp_add_dosen`
Adds a new lecturer with user account.

**Parameters:**
```sql
p_username, p_password, p_nip, p_nama_lengkap, p_gelar_depan,
p_gelar_belakang, p_email, p_no_telepon, p_jenis_kelamin
```

### 3. `sp_record_absensi`
Records or updates student attendance.

**Parameters:**
```sql
p_jadwal_id, p_nim, p_tanggal, p_status_kehadiran, p_keterangan
```

**Example:**
```sql
EXEC sp_record_absensi(1, '3122500012', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 
    'Hadir', NULL);
```

### 4. `sp_input_nilai`
Records or updates student grades.

**Parameters:**
```sql
p_nim, p_kode_matkul, p_tahun_ajaran, p_nilai_tugas, p_nilai_uts, p_nilai_uas
```

**Example:**
```sql
EXEC sp_input_nilai('3122500012', 'TI301', '2024/2025', 85, 90, 88);
```

## Functions

### 1. `fn_calculate_ipk(p_nim)`
Calculates student's GPA (IPK).

**Example:**
```sql
SELECT fn_calculate_ipk('3122500012') AS ipk FROM dual;
```

### 2. `fn_get_attendance_percentage(p_nim, p_kode_matkul, p_tahun_ajaran)`
Gets attendance percentage for a student in a course.

**Example:**
```sql
SELECT fn_get_attendance_percentage('3122500012', 'TI301', '2024/2025') 
AS persentase_kehadiran FROM dual;
```

## Views

### 1. `vw_student_dashboard`
Student dashboard overview with program and class information.

### 2. `vw_lecturer_dashboard`
Lecturer dashboard with course statistics.

### 3. `vw_student_grades`
Complete student grades report.

### 4. `vw_attendance_report`
Detailed attendance records.

### 5. `vw_jadwal_lengkap`
Complete course schedule with all details.

## Installation Steps

### 1. **Connect to Oracle Database**
```sql
sqlplus username/password@database
```

### 2. **Create Schema**
```sql
@oracle_schema.sql
```

### 3. **Insert Sample Data**
```sql
@sample_data.sql
```

### 4. **Create Procedures and Views**
```sql
@procedures_views.sql
```

## Common Queries

### Get Student Schedule
```sql
SELECT * FROM vw_jadwal_lengkap
WHERE nama_kelas = (
    SELECT k.nama_kelas
    FROM mahasiswa m
    JOIN kelas_mahasiswa km ON m.mahasiswa_id = km.mahasiswa_id
    JOIN kelas k ON km.kelas_id = k.kelas_id
    WHERE m.nim = '3122500012'
);
```

### Get Student Grades
```sql
SELECT * FROM vw_student_grades
WHERE nim = '3122500012';
```

### Get Attendance Report
```sql
SELECT * FROM vw_attendance_report
WHERE nim = '3122500012'
  AND nama_matkul = 'Pemrograman Web';
```

### Check Student GPA
```sql
SELECT nim, nama_lengkap, fn_calculate_ipk(nim) AS ipk
FROM mahasiswa
WHERE nim = '3122500012';
```

## Backup and Restore

### Export Database
```bash
expdp username/password@database directory=DATA_PUMP_DIR dumpfile=smartcampus.dmp schemas=SMARTCAMPUS
```

### Import Database
```bash
impdp username/password@database directory=DATA_PUMP_DIR dumpfile=smartcampus.dmp schemas=SMARTCAMPUS
```

## Security Recommendations

1. **Password Encryption**: Use Oracle's DBMS_CRYPTO package to encrypt passwords
2. **Role-Based Access**: Create Oracle roles for admin, dosen, and mahasiswa
3. **SSL/TLS**: Enable encrypted connections
4. **Audit Trail**: Enable Oracle auditing for sensitive operations
5. **Regular Backups**: Schedule automated backups

## Performance Optimization

1. All frequently queried columns have indexes
2. Use materialized views for complex reports
3. Partition large tables (absensi, nilai) by academic year
4. Regular statistics gathering: `EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SMARTCAMPUS');`

## Maintenance

### Rebuild Indexes
```sql
ALTER INDEX index_name REBUILD;
```

### Update Statistics
```sql
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SMARTCAMPUS');
```

### Check Invalid Objects
```sql
SELECT object_name, object_type 
FROM user_objects 
WHERE status = 'INVALID';
```

## Support
For questions or issues, contact the database administrator.

---
**Version**: 1.0  
**Last Updated**: November 2025  
**Database**: Oracle 11g/12c/19c+
