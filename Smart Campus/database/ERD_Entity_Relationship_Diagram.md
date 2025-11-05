# Entity Relationship Diagram (ERD) - Smart Campus Database

## ERD Overview
This document provides the Entity Relationship Diagram for the Smart Campus Management System using Oracle Database.

## ERD Notation Legend

```
┌─────────────┐
│  ENTITY     │  = Table/Entity
└─────────────┘

───────────────  = Relationship Line
      │
     PK          = Primary Key
     FK          = Foreign Key
     U           = Unique
     NN          = Not Null

1:1              = One-to-One Relationship
1:N              = One-to-Many Relationship
N:M              = Many-to-Many Relationship
```

---

## Complete ERD Diagram (Text-Based)

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                          SMART CAMPUS DATABASE SCHEMA                           │
└────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────┐
│        USERS            │
├─────────────────────────┤
│ PK  user_id            │
│ U   username           │
│ NN  password           │
│ U   email              │
│ NN  role               │
│     is_active          │
│     created_at         │
│     updated_at         │
│     last_login         │
└───────────┬─────────────┘
            │
            │ 1:1
            │
      ┌─────┴────────┬──────────────┐
      │              │              │
      │              │              │
┌─────▼──────────┐  │  ┌───────────▼────────┐
│    DOSEN       │  │  │    MAHASISWA       │
├────────────────┤  │  ├────────────────────┤
│ PK dosen_id    │  │  │ PK mahasiswa_id    │
│ FK user_id ────┼──┘  │ FK user_id ────────┤
│ U  nip         │     │ FK prodi_id ───────┼──┐
│    nama_lengkap│     │ U  nim             │  │
│    gelar_depan │     │    nama_lengkap    │  │
│    gelar_belkng│     │    email           │  │
│    email       │     │    no_telepon      │  │
│    no_telepon  │     │    alamat          │  │
│    alamat      │     │    tanggal_lahir   │  │
│    tgl_lahir   │     │    jenis_kelamin   │  │
│    jenis_klmin │     │    angkatan        │  │
│    created_at  │     │    semester        │  │
│    updated_at  │     │    status          │  │
└────────┬───────┘     │    created_at      │  │
         │             │    updated_at      │  │
         │ 1:N         └────────┬───────────┘  │
         │                      │              │
         │                      │ N:M          │
         │                      │              │
         │              ┌───────▼──────────┐   │
         │              │ KELAS_MAHASISWA  │   │
         │              ├──────────────────┤   │
         │              │ PK km_id         │   │
         │              │ FK kelas_id ─────┼─┐ │
         │              │ FK mahasiswa_id  │ │ │
         │              │    tahun_ajaran  │ │ │
         │              │    status        │ │ │
         │              │    created_at    │ │ │
         │              └──────────────────┘ │ │
         │                                   │ │
         │                                   │ │
    ┌────▼────────────────┐        ┌────────▼─▼──────────┐
    │   MATA_KULIAH       │        │       KELAS         │
    ├─────────────────────┤        ├─────────────────────┤
    │ PK  matkul_id       │        │ PK  kelas_id        │
    │ FK  prodi_id ───────┼───┐    │ FK  prodi_id ───────┼──┐
    │ FK  dosen_id        │   │    │     kode_kelas      │  │
    │ U   kode_matkul     │   │    │     nama_kelas      │  │
    │     nama_matkul     │   │    │     semester        │  │
    │     sks             │   │    │     tahun_ajaran    │  │
    │     semester        │   │    │     created_at      │  │
    │     jenis_matkul    │   │    │     updated_at      │  │
    │     deskripsi       │   │    └─────────┬───────────┘  │
    │     created_at      │   │              │              │
    │     updated_at      │   │              │ 1:N          │
    └──────┬──────────────┘   │              │              │
           │                  │      ┌───────▼──────────┐   │
           │ 1:N              │      │  JADWAL_KULIAH   │   │
           │                  │      ├──────────────────┤   │
           │                  │      │ PK jadwal_id     │   │
           │                  │      │ FK kelas_id      │   │
           │                  │      │ FK matkul_id ────┼───┤
           │                  │      │ FK dosen_id ─────┼─┐ │
           │                  │      │    hari          │ │ │
           │                  │      │    jam_mulai     │ │ │
           │                  │      │    jam_selesai   │ │ │
           │                  │      │    ruangan       │ │ │
           │                  │      │    tahun_ajaran  │ │ │
           │                  │      │    created_at    │ │ │
           │                  │      │    updated_at    │ │ │
           │                  │      └─────────┬────────┘ │ │
           │                  │                │          │ │
           │                  │                │ 1:N      │ │
           │                  │                │          │ │
           │                  │        ┌───────▼────────┐ │ │
           │                  │        │    ABSENSI     │ │ │
           │                  │        ├────────────────┤ │ │
           │                  │        │ PK absensi_id  │ │ │
           │                  │        │ FK jadwal_id   │ │ │
           │                  │        │ FK mahasiswa_id├─┼─┤
           │                  │        │    tanggal     │ │ │
           │                  │        │    status_hdr  │ │ │
           │                  │        │    keterangan  │ │ │
           │                  │        │    created_at  │ │ │
           │                  │        │    updated_at  │ │ │
           │                  │        └────────────────┘ │ │
           │                  │                           │ │
           │ 1:N              │                           │ │
           │                  │                           │ │
    ┌──────▼──────────┐       │                           │ │
    │     NILAI       │       │                           │ │
    ├─────────────────┤       │                           │ │
    │ PK  nilai_id    │       │                           │ │
    │ FK  mahasiswa_id├───────┼───────────────────────────┘ │
    │ FK  matkul_id   │       │                             │
    │     tahun_ajaran│       │                             │
    │     nilai_tugas │       │                             │
    │     nilai_uts   │       │                             │
    │     nilai_uas   │       │                             │
    │     nilai_akhir │       │                             │
    │     grade       │       │                             │
    │     status      │       │                             │
    │     created_at  │       │                             │
    │     updated_at  │       │                             │
    └─────────────────┘       │                             │
                              │                             │
                              │                             │
                    ┌─────────▼─────────────────────────────┘
                    │
            ┌───────▼──────────┐
            │  PROGRAM_STUDI   │
            ├──────────────────┤
            │ PK  prodi_id     │
            │ U   kode_prodi   │
            │     nama_prodi   │
            │     jenjang      │
            │     fakultas     │
            │     created_at   │
            │     updated_at   │
            └──────────────────┘
```

---

## Detailed Relationship Descriptions

### 1. USER ↔ DOSEN (1:1)
- **Cardinality**: One user can be one dosen, one dosen has one user account
- **Foreign Key**: `dosen.user_id` → `users.user_id`
- **Delete Rule**: CASCADE (deleting user deletes dosen record)
- **Business Rule**: Each lecturer must have exactly one user account

### 2. USER ↔ MAHASISWA (1:1)
- **Cardinality**: One user can be one mahasiswa, one mahasiswa has one user account
- **Foreign Key**: `mahasiswa.user_id` → `users.user_id`
- **Delete Rule**: CASCADE (deleting user deletes mahasiswa record)
- **Business Rule**: Each student must have exactly one user account

### 3. PROGRAM_STUDI ↔ MAHASISWA (1:N)
- **Cardinality**: One program has many students, one student belongs to one program
- **Foreign Key**: `mahasiswa.prodi_id` → `program_studi.prodi_id`
- **Delete Rule**: RESTRICT (cannot delete program with enrolled students)
- **Business Rule**: Students must be enrolled in a program

### 4. PROGRAM_STUDI ↔ MATA_KULIAH (1:N)
- **Cardinality**: One program has many courses, one course belongs to one program
- **Foreign Key**: `mata_kuliah.prodi_id` → `program_studi.prodi_id`
- **Delete Rule**: RESTRICT (cannot delete program with courses)
- **Business Rule**: Courses are program-specific

### 5. PROGRAM_STUDI ↔ KELAS (1:N)
- **Cardinality**: One program has many classes, one class belongs to one program
- **Foreign Key**: `kelas.prodi_id` → `program_studi.prodi_id`
- **Delete Rule**: RESTRICT (cannot delete program with classes)
- **Business Rule**: Classes are organized per program

### 6. DOSEN ↔ MATA_KULIAH (1:N)
- **Cardinality**: One lecturer teaches many courses, one course taught by one lecturer
- **Foreign Key**: `mata_kuliah.dosen_id` → `dosen.dosen_id`
- **Delete Rule**: SET NULL (course remains if lecturer deleted)
- **Business Rule**: Courses can be reassigned to different lecturers

### 7. KELAS ↔ MAHASISWA (N:M via KELAS_MAHASISWA)
- **Cardinality**: Many students can enroll in many classes
- **Junction Table**: `kelas_mahasiswa`
- **Foreign Keys**: 
  - `kelas_mahasiswa.kelas_id` → `kelas.kelas_id`
  - `kelas_mahasiswa.mahasiswa_id` → `mahasiswa.mahasiswa_id`
- **Delete Rule**: CASCADE (enrollment deleted if class or student deleted)
- **Business Rule**: Students enroll in classes per academic year

### 8. KELAS + MATA_KULIAH + DOSEN ↔ JADWAL_KULIAH (Composite)
- **Cardinality**: One class can have many schedules
- **Foreign Keys**: 
  - `jadwal_kuliah.kelas_id` → `kelas.kelas_id`
  - `jadwal_kuliah.matkul_id` → `mata_kuliah.matkul_id`
  - `jadwal_kuliah.dosen_id` → `dosen.dosen_id`
- **Delete Rule**: CASCADE for class/course, RESTRICT for dosen
- **Business Rule**: Schedule combines class, course, lecturer, time, and room

### 9. JADWAL_KULIAH + MAHASISWA ↔ ABSENSI (Composite)
- **Cardinality**: One schedule can have many attendance records
- **Foreign Keys**: 
  - `absensi.jadwal_id` → `jadwal_kuliah.jadwal_id`
  - `absensi.mahasiswa_id` → `mahasiswa.mahasiswa_id`
- **Delete Rule**: CASCADE (attendance deleted if schedule or student deleted)
- **Unique Constraint**: One attendance record per student per schedule per date
- **Business Rule**: Attendance tracked per class session

### 10. MAHASISWA + MATA_KULIAH ↔ NILAI (Composite)
- **Cardinality**: One student can have many grades, one course can have many grades
- **Foreign Keys**: 
  - `nilai.mahasiswa_id` → `mahasiswa.mahasiswa_id`
  - `nilai.matkul_id` → `mata_kuliah.matkul_id`
- **Delete Rule**: CASCADE (grades deleted if student or course deleted)
- **Unique Constraint**: One grade record per student per course per academic year
- **Business Rule**: Grades recorded per academic year

---

## ERD Cardinality Summary

| Relationship | From | To | Type | Description |
|--------------|------|-----|------|-------------|
| R1 | users | dosen | 1:1 | User account for lecturer |
| R2 | users | mahasiswa | 1:1 | User account for student |
| R3 | program_studi | mahasiswa | 1:N | Students enrolled in program |
| R4 | program_studi | mata_kuliah | 1:N | Courses in program |
| R5 | program_studi | kelas | 1:N | Classes in program |
| R6 | dosen | mata_kuliah | 1:N | Lecturer teaches courses |
| R7 | dosen | jadwal_kuliah | 1:N | Lecturer's teaching schedule |
| R8 | kelas | kelas_mahasiswa | 1:N | Class enrollment |
| R9 | mahasiswa | kelas_mahasiswa | 1:N | Student enrollment |
| R10 | kelas | jadwal_kuliah | 1:N | Class schedules |
| R11 | mata_kuliah | jadwal_kuliah | 1:N | Course schedules |
| R12 | jadwal_kuliah | absensi | 1:N | Attendance per schedule |
| R13 | mahasiswa | absensi | 1:N | Student attendance records |
| R14 | mahasiswa | nilai | 1:N | Student grades |
| R15 | mata_kuliah | nilai | 1:N | Course grades |

---

## ERD in Chen Notation

```
                                    ┌─────────┐
                                    │  USERS  │
                                    └────┬────┘
                                         │
                            ┌────────────┼────────────┐
                            │            │            │
                         has│1        has│1        has│1
                            │            │            │
                    ┌───────▼──┐    ┌────▼────┐    ┌─▼──────┐
                    │  DOSEN   │    │  ADMIN  │    │MAHASIS │
                    │          │    │         │    │  WA    │
                    └────┬─────┘    └─────────┘    └───┬────┘
                         │                              │
                    teaches│N                    enrolled│N
                         │                              │
                    ┌────▼────┐                    ┌────▼────┐
                    │  MATA   │1                   │ PROGRAM │
                    │ KULIAH  ├────────belongs─────┤  STUDI  │
                    └────┬────┘      to       1    └────┬────┘
                         │                              │
                    has  │N                        has  │1
                         │                              │
                    ┌────▼─────┐                   ┌────▼────┐
                    │ JADWAL   │1        belongs   │  KELAS  │
                    │ KULIAH   ├───────────to──────┤         │
                    └────┬─────┘           N       └────┬────┘
                         │                              │
                         │N                        N    │
                         │                              │
                    ┌────▼────┐                    ┌────▼────┐
                    │ ABSENSI │                    │  KELAS  │
                    │         │◄────records────────┤MAHASISWA│
                    └─────────┘       N:M          └─────────┘
                                                         │
                                                    has  │N
                                                         │
                                                    ┌────▼────┐
                                                    │  NILAI  │
                                                    │         │
                                                    └─────────┘
```

---

## ERD Key Constraints

### Primary Keys (PK)
- All tables have auto-generated numeric primary keys using Oracle sequences
- Primary key constraints ensure unique identification of each record

### Foreign Keys (FK)
- All relationships implemented with foreign key constraints
- Referential integrity enforced at database level
- Cascade rules defined based on business logic

### Unique Constraints (UK)
- `users.username` - No duplicate usernames
- `users.email` - No duplicate emails
- `dosen.nip` - Unique lecturer ID
- `mahasiswa.nim` - Unique student ID
- `program_studi.kode_prodi` - Unique program code
- `mata_kuliah.kode_matkul` - Unique course code
- `kelas.kode_kelas` - Unique class code
- Composite unique constraints on junction tables

### Check Constraints (CK)
- `users.role` IN ('admin', 'dosen', 'mahasiswa')
- `mahasiswa.jenis_kelamin` IN ('L', 'P')
- `mahasiswa.status` IN ('Aktif', 'Cuti', 'Lulus', 'DO')
- `mata_kuliah.sks` > 0
- `nilai.nilai_*` BETWEEN 0 AND 100
- `absensi.status_kehadiran` IN ('Hadir', 'Izin', 'Sakit', 'Alpa')
- `jadwal_kuliah.hari` IN (days of week)

---

## ERD Normalization Level

The database schema follows **Third Normal Form (3NF)**:

### 1NF (First Normal Form)
✅ All attributes contain atomic values
✅ No repeating groups
✅ Each column has a unique name

### 2NF (Second Normal Form)
✅ All non-key attributes fully dependent on primary key
✅ No partial dependencies
✅ Proper use of composite keys

### 3NF (Third Normal Form)
✅ No transitive dependencies
✅ All non-key attributes directly depend on primary key
✅ Minimal redundancy

---

## ERD Best Practices Applied

1. ✅ **Meaningful Names**: All tables and columns use descriptive names
2. ✅ **Consistent Naming**: Following Indonesian naming conventions
3. ✅ **Proper Data Types**: Appropriate Oracle data types for each column
4. ✅ **Referential Integrity**: All relationships enforced with FK constraints
5. ✅ **Indexing**: Strategic indexes on foreign keys and search columns
6. ✅ **Audit Trail**: created_at and updated_at on all tables
7. ✅ **Cascade Rules**: Appropriate ON DELETE rules for each relationship
8. ✅ **Constraints**: Business rules enforced at database level

---

**Version**: 1.0  
**Last Updated**: November 2025  
**Notation**: Crow's Foot with Chen elements  
**Tool Recommendation**: Oracle SQL Developer Data Modeler, ERDPlus, draw.io
