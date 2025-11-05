# Conceptual Data Model (CDM) - Smart Campus

## Overview
The Conceptual Data Model represents the high-level business concepts and their relationships in the Smart Campus system.

## Main Entities

### 1. USER
**Description**: Represents all users in the system
- **Attributes**:
  - User ID
  - Username
  - Password
  - Email
  - Role (Admin, Lecturer, Student)
  - Active Status
  - Login Information

### 2. STUDENT (MAHASISWA)
**Description**: Represents students enrolled in the campus
- **Attributes**:
  - Student ID
  - Student Number (NIM)
  - Full Name
  - Contact Information (Email, Phone)
  - Address
  - Date of Birth
  - Gender
  - Enrollment Year
  - Current Semester
  - Status (Active, Leave, Graduated, Dropped Out)

### 3. LECTURER (DOSEN)
**Description**: Represents faculty members who teach courses
- **Attributes**:
  - Lecturer ID
  - National ID Number (NIP)
  - Full Name
  - Academic Titles (Prefix, Suffix)
  - Contact Information
  - Address
  - Date of Birth
  - Gender

### 4. PROGRAM OF STUDY (PROGRAM STUDI)
**Description**: Represents academic programs/majors
- **Attributes**:
  - Program ID
  - Program Code
  - Program Name
  - Education Level (D3, D4, S1, S2)
  - Faculty

### 5. COURSE (MATA KULIAH)
**Description**: Represents academic courses/subjects
- **Attributes**:
  - Course ID
  - Course Code
  - Course Name
  - Credit Hours (SKS)
  - Semester
  - Course Type (Mandatory, Elective)
  - Description

### 6. CLASS (KELAS)
**Description**: Represents class groups
- **Attributes**:
  - Class ID
  - Class Code
  - Class Name
  - Semester Level
  - Academic Year

### 7. SCHEDULE (JADWAL KULIAH)
**Description**: Represents course schedules
- **Attributes**:
  - Schedule ID
  - Day of Week
  - Start Time
  - End Time
  - Room/Location
  - Academic Year

### 8. ATTENDANCE (ABSENSI)
**Description**: Represents student attendance records
- **Attributes**:
  - Attendance ID
  - Date
  - Attendance Status (Present, Absent with Permission, Sick, Absent)
  - Notes

### 9. GRADE (NILAI)
**Description**: Represents student academic grades
- **Attributes**:
  - Grade ID
  - Assignment Grade
  - Midterm Exam Grade (UTS)
  - Final Exam Grade (UAS)
  - Final Grade
  - Letter Grade (A, B, C, D, E)
  - Pass Status
  - Academic Year

### 10. ENROLLMENT (KELAS MAHASISWA)
**Description**: Represents student enrollment in classes
- **Attributes**:
  - Enrollment ID
  - Academic Year
  - Status

## Entity Relationships

### Core Relationships

1. **USER ← STUDENT** (1:1)
   - One User account belongs to one Student
   - One Student has one User account

2. **USER ← LECTURER** (1:1)
   - One User account belongs to one Lecturer
   - One Lecturer has one User account

3. **PROGRAM OF STUDY → STUDENT** (1:N)
   - One Program has many Students
   - One Student belongs to one Program

4. **PROGRAM OF STUDY → COURSE** (1:N)
   - One Program has many Courses
   - One Course belongs to one Program

5. **PROGRAM OF STUDY → CLASS** (1:N)
   - One Program has many Classes
   - One Class belongs to one Program

6. **LECTURER → COURSE** (1:N)
   - One Lecturer teaches many Courses
   - One Course is taught by one Lecturer

7. **CLASS ← ENROLLMENT → STUDENT** (M:N)
   - Many Students can enroll in many Classes
   - Implemented through ENROLLMENT entity

8. **CLASS → SCHEDULE ← COURSE** (1:N)
   - One Class has many Schedules
   - One Course appears in many Schedules

9. **SCHEDULE → ATTENDANCE** (1:N)
   - One Schedule has many Attendance records
   - One Attendance record belongs to one Schedule

10. **STUDENT → ATTENDANCE** (1:N)
    - One Student has many Attendance records
    - One Attendance record belongs to one Student

11. **STUDENT → GRADE** (1:N)
    - One Student has many Grades
    - One Grade belongs to one Student

12. **COURSE → GRADE** (1:N)
    - One Course has many Grades
    - One Grade belongs to one Course

## Business Rules

1. **User Authentication**
   - Each user must have a unique username and email
   - Users are categorized into three roles: Admin, Lecturer, Student
   - Only active users can access the system

2. **Student Management**
   - Each student must be enrolled in one program of study
   - Students must have a unique student number (NIM)
   - Students can be in Active, Leave, Graduated, or Dropped Out status

3. **Lecturer Management**
   - Each lecturer must have a unique national ID (NIP)
   - Lecturers can teach multiple courses
   - Lecturers can have academic titles

4. **Course Management**
   - Each course has a specific number of credit hours (SKS)
   - Courses can be Mandatory or Elective
   - Courses are assigned to specific semesters and programs

5. **Class and Enrollment**
   - Students enroll in classes for specific academic years
   - Each class belongs to one program and semester level
   - Classes have unique codes

6. **Schedule Management**
   - Each schedule must specify day, time, and room
   - Schedules link classes, courses, and lecturers
   - Multiple schedules can exist for the same course in different classes

7. **Attendance Tracking**
   - Attendance is recorded per schedule per student
   - Attendance statuses: Present, Absent with Permission, Sick, Absent
   - Each attendance record is for a specific date

8. **Grading System**
   - Grades consist of: Assignment (30%), Midterm (30%), Final Exam (40%)
   - Final grade is automatically calculated
   - Letter grades: A (≥85), B (≥75), C (≥65), D (≥55), E (<55)
   - Students with grades A, B, or C pass the course

## Data Integrity Rules

1. **Referential Integrity**
   - All foreign key relationships must maintain referential integrity
   - Cascade delete for dependent records where appropriate

2. **Domain Integrity**
   - Grades must be between 0 and 100
   - Gender must be 'L' (Male) or 'P' (Female)
   - Attendance status must be one of the defined values
   - Credit hours must be positive numbers

3. **Entity Integrity**
   - All entities must have a unique primary key
   - Primary keys cannot be null

4. **User-Defined Integrity**
   - Academic year must follow format "YYYY/YYYY"
   - Time values must be valid (00:00 - 23:59)
   - Email addresses must be unique and valid format

## Conceptual Model Diagram

```
┌─────────────┐
│    USER     │
└──────┬──────┘
       │ 1:1
       ├──────────────┬──────────────┐
       │              │              │
┌──────▼──────┐ ┌────▼─────┐ ┌─────▼──────┐
│   STUDENT   │ │  LECTURER│ │   ADMIN    │
└──────┬──────┘ └────┬─────┘ └────────────┘
       │             │
       │ N:1         │ 1:N
       │             │
┌──────▼──────┐ ┌───▼────────┐
│  PROGRAM    │ │   COURSE   │
│  OF STUDY   │ │            │
└──────┬──────┘ └─────┬──────┘
       │              │
       │ 1:N          │ N:1
       │              │
┌──────▼──────┐      │
│    CLASS    │◄─────┘
└──────┬──────┘
       │ 1:N
       │
┌──────▼──────┐
│  SCHEDULE   │
└──────┬──────┘
       │ 1:N
       │
┌──────▼──────────┐
│   ATTENDANCE    │
└─────────────────┘

┌─────────────┐      ┌─────────────┐
│   STUDENT   │◄────►│    GRADE    │
└─────────────┘  N:N └──────┬──────┘
                            │
                            │ N:1
                            ▼
                     ┌─────────────┐
                     │   COURSE    │
                     └─────────────┘
```

## Notes

- This CDM focuses on the business perspective
- Technical implementation details are in the PDM
- The model supports multi-semester, multi-year academic operations
- Designed for scalability and future enhancements
- All timestamps and audit fields are maintained automatically

---
**Version**: 1.0  
**Last Updated**: November 2025  
**Model Type**: Conceptual Data Model
