/*
PROJECT: Healthcare Management & Operations Database (Improved V2)
PLATFORM: Microsoft SQL Server (SSMS)
DATA: Synthetic, clean, reproducible sample data with varied appointment and payment patterns
CONTENTS: 6 related tables + sample data + validation queries

HOW TO USE:
1. Open this file in SQL Server Management Studio.
2. Execute the whole script (F5).
3. Refresh Databases in Object Explorer.
4. Expand HealthcareManagement_Improved > Tables.
5. Start your analysis using the suggested starter queries at the end.

NOTE:
- The records are fictional and created for SQL practice.
- This V2 keeps the same six-table structure and all 1,000 patient records.
- Appointment assignments, appointment types/statuses, and bill payment patterns are more varied.
- The original HealthcareManagement database is not changed.
- Re-running this script drops and recreates HealthcareManagement_Improved.
*/

USE master;
GO

IF DB_ID(N'HealthcareManagement_Improved') IS NOT NULL
BEGIN
    ALTER DATABASE HealthcareManagement_Improved SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HealthcareManagement_Improved;
END;
GO

CREATE DATABASE HealthcareManagement_Improved;
GO

USE HealthcareManagement_Improved;
GO

/*==============================================================
  1. TABLES
==============================================================*/

CREATE TABLE dbo.Departments
(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(80) NOT NULL UNIQUE,
    Location NVARCHAR(80) NOT NULL
);
GO

CREATE TABLE dbo.Doctors
(
    DoctorID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('F','M')),
    Specialty NVARCHAR(80) NOT NULL,
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,
    ConsultationFee DECIMAL(10,2) NOT NULL CHECK (ConsultationFee >= 0),
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Doctors_Departments
        FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID)
);
GO

CREATE TABLE dbo.Patients
(
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('F','M')),
    DateOfBirth DATE NOT NULL,
    City NVARCHAR(80) NOT NULL,
    RegistrationDate DATE NOT NULL,
    InsuranceProvider NVARCHAR(80) NULL,
    CONSTRAINT CK_Patients_DOB CHECK (DateOfBirth < RegistrationDate)
);
GO

CREATE TABLE dbo.Appointments
(
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME2(0) NOT NULL,
    AppointmentType NVARCHAR(30) NOT NULL
        CHECK (AppointmentType IN ('Consultation','Follow-up','Emergency')),
    Status NVARCHAR(20) NOT NULL
        CHECK (Status IN ('Completed','Cancelled','No-show','Scheduled')),
    Reason NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Appointments_Patients
        FOREIGN KEY (PatientID) REFERENCES dbo.Patients(PatientID),
    CONSTRAINT FK_Appointments_Doctors
        FOREIGN KEY (DoctorID) REFERENCES dbo.Doctors(DoctorID)
);
GO

CREATE TABLE dbo.Treatments
(
    TreatmentID INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID INT NOT NULL,
    TreatmentName NVARCHAR(100) NOT NULL,
    TreatmentCategory NVARCHAR(60) NOT NULL,
    TreatmentCost DECIMAL(10,2) NOT NULL CHECK (TreatmentCost >= 0),
    CONSTRAINT FK_Treatments_Appointments
        FOREIGN KEY (AppointmentID) REFERENCES dbo.Appointments(AppointmentID)
);
GO

CREATE TABLE dbo.Bills
(
    BillID INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID INT NOT NULL UNIQUE,
    BillDate DATE NOT NULL,
    ConsultationAmount DECIMAL(10,2) NOT NULL CHECK (ConsultationAmount >= 0),
    TreatmentAmount DECIMAL(10,2) NOT NULL CHECK (TreatmentAmount >= 0),
    DiscountAmount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (DiscountAmount >= 0),
    TotalAmount AS (ConsultationAmount + TreatmentAmount - DiscountAmount) PERSISTED,
    PaymentStatus NVARCHAR(20) NOT NULL
        CHECK (PaymentStatus IN ('Paid','Partially Paid','Unpaid')),
    PaymentMethod NVARCHAR(30) NULL
        CHECK (PaymentMethod IN ('Cash','Card','Insurance','Bank Transfer') OR PaymentMethod IS NULL),
    AmountPaid DECIMAL(10,2) NOT NULL CHECK (AmountPaid >= 0),
    CONSTRAINT FK_Bills_Appointments
        FOREIGN KEY (AppointmentID) REFERENCES dbo.Appointments(AppointmentID),
    CONSTRAINT CK_Bills_AmountPaid CHECK
        (AmountPaid <= ConsultationAmount + TreatmentAmount - DiscountAmount)
);
GO

/* Helpful indexes for common joins and date filtering */
CREATE INDEX IX_Appointments_AppointmentDate ON dbo.Appointments(AppointmentDate);
CREATE INDEX IX_Appointments_PatientID ON dbo.Appointments(PatientID);
CREATE INDEX IX_Appointments_DoctorID ON dbo.Appointments(DoctorID);
CREATE INDEX IX_Treatments_AppointmentID ON dbo.Treatments(AppointmentID);
GO

/*==============================================================
  2. DEPARTMENTS
==============================================================*/

INSERT INTO dbo.Departments (DepartmentName, Location)
VALUES
(N'Cardiology', N'Building A - Floor 2'),
(N'Dermatology', N'Building A - Floor 1'),
(N'Neurology', N'Building B - Floor 3'),
(N'Pediatrics', N'Building B - Floor 1'),
(N'Orthopedics', N'Building C - Floor 2'),
(N'General Medicine', N'Building A - Floor 3'),
(N'Dentistry', N'Building C - Floor 1'),
(N'Ophthalmology', N'Building B - Floor 2');
GO

/*==============================================================
  3. DOCTORS: 32 doctors
==============================================================*/

;WITH DoctorSeed AS
(
    SELECT *
    FROM (VALUES
      (N'Olivia',N'Brown','F',N'Cardiology',1,CAST('2018-03-12' AS DATE),650.00),
      (N'James',N'Wilson','M',N'Cardiology',1,CAST('2019-06-18' AS DATE),600.00),
      (N'Sophia',N'Taylor','F',N'Cardiology',1,CAST('2021-01-10' AS DATE),700.00),
      (N'Noah',N'Martin','M',N'Cardiology',1,CAST('2020-09-05' AS DATE),620.00),
      (N'Emma',N'Anderson','F',N'Dermatology',2,CAST('2017-11-20' AS DATE),550.00),
      (N'Liam',N'Thomas','M',N'Dermatology',2,CAST('2022-02-14' AS DATE),500.00),
      (N'Ava',N'Jackson','F',N'Dermatology',2,CAST('2019-04-08' AS DATE),580.00),
      (N'Lucas',N'White','M',N'Dermatology',2,CAST('2020-07-22' AS DATE),520.00),
      (N'Mia',N'Harris','F',N'Neurology',3,CAST('2016-05-16' AS DATE),800.00),
      (N'Ethan',N'Clark','M',N'Neurology',3,CAST('2018-08-01' AS DATE),750.00),
      (N'Isabella',N'Lewis','F',N'Neurology',3,CAST('2021-12-01' AS DATE),780.00),
      (N'Mason',N'Walker','M',N'Neurology',3,CAST('2023-01-09' AS DATE),700.00),
      (N'Amelia',N'Young','F',N'Pediatrics',4,CAST('2017-02-11' AS DATE),500.00),
      (N'Logan',N'Allen','M',N'Pediatrics',4,CAST('2020-10-19' AS DATE),480.00),
      (N'Harper',N'King','F',N'Pediatrics',4,CAST('2019-03-25' AS DATE),520.00),
      (N'Elijah',N'Wright','M',N'Pediatrics',4,CAST('2022-06-13' AS DATE),490.00),
      (N'Evelyn',N'Scott','F',N'Orthopedics',5,CAST('2015-09-07' AS DATE),700.00),
      (N'Oliver',N'Green','M',N'Orthopedics',5,CAST('2018-04-17' AS DATE),680.00),
      (N'Abigail',N'Baker','F',N'Orthopedics',5,CAST('2021-07-29' AS DATE),720.00),
      (N'Leo',N'Adams','M',N'Orthopedics',5,CAST('2022-11-03' AS DATE),650.00),
      (N'Emily',N'Nelson','F',N'General Medicine',6,CAST('2016-01-15' AS DATE),400.00),
      (N'Benjamin',N'Hill','M',N'General Medicine',6,CAST('2019-05-21' AS DATE),420.00),
      (N'Ella',N'Campbell','F',N'General Medicine',6,CAST('2020-02-02' AS DATE),390.00),
      (N'Jack',N'Mitchell','M',N'General Medicine',6,CAST('2023-03-14' AS DATE),410.00),
      (N'Scarlett',N'Roberts','F',N'Dentistry',7,CAST('2017-08-08' AS DATE),450.00),
      (N'Henry',N'Carter','M',N'Dentistry',7,CAST('2020-12-12' AS DATE),430.00),
      (N'Grace',N'Phillips','F',N'Dentistry',7,CAST('2021-04-19' AS DATE),470.00),
      (N'Alexander',N'Evans','M',N'Dentistry',7,CAST('2022-09-26' AS DATE),440.00),
      (N'Chloe',N'Turner','F',N'Ophthalmology',8,CAST('2018-10-10' AS DATE),520.00),
      (N'Daniel',N'Parker','M',N'Ophthalmology',8,CAST('2019-01-30' AS DATE),500.00),
      (N'Lily',N'Collins','F',N'Ophthalmology',8,CAST('2021-06-06' AS DATE),540.00),
      (N'William',N'Edwards','M',N'Ophthalmology',8,CAST('2023-02-20' AS DATE),510.00)
    ) AS D(FirstName,LastName,Gender,Specialty,DepartmentID,HireDate,ConsultationFee)
)
INSERT INTO dbo.Doctors
    (FirstName,LastName,Gender,Specialty,DepartmentID,HireDate,ConsultationFee)
SELECT FirstName,LastName,Gender,Specialty,DepartmentID,HireDate,ConsultationFee
FROM DoctorSeed;
GO

/*==============================================================
  4. PATIENTS: 1,000 fictional patients
==============================================================*/

;WITH Numbers AS
(
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
FirstNames AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n, FirstName
    FROM (VALUES
      (N'Olivia'),(N'Liam'),(N'Emma'),(N'Noah'),(N'Amelia'),
      (N'Oliver'),(N'Ava'),(N'Elijah'),(N'Sophia'),(N'Lucas'),
      (N'Mia'),(N'Mason'),(N'Isabella'),(N'Ethan'),(N'Evelyn'),
      (N'James'),(N'Charlotte'),(N'Benjamin'),(N'Harper'),(N'Jack')
    ) v(FirstName)
),
LastNames AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n, LastName
    FROM (VALUES
      (N'Smith'),(N'Johnson'),(N'Williams'),(N'Brown'),(N'Jones'),
      (N'Garcia'),(N'Miller'),(N'Davis'),(N'Rodriguez'),(N'Martinez'),
      (N'Hernandez'),(N'Lopez'),(N'Gonzalez'),(N'Wilson'),(N'Anderson'),
      (N'Thomas'),(N'Taylor'),(N'Moore'),(N'Jackson'),(N'Martin')
    ) v(LastName)
),
Cities AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n, City
    FROM (VALUES
      (N'Cairo'),(N'Giza'),(N'Alexandria'),(N'Tanta'),(N'Mansoura'),
      (N'Zagazig'),(N'Ismailia'),(N'Port Said'),(N'Fayoum'),(N'Aswan')
    ) v(City)
)
INSERT INTO dbo.Patients
    (FirstName,LastName,Gender,DateOfBirth,City,RegistrationDate,InsuranceProvider)
SELECT
    fn.FirstName,
    ln.LastName,
    CASE WHEN n.n % 2 = 0 THEN 'F' ELSE 'M' END,
    DATEADD(DAY, - (7000 + (n.n * 37 % 18000)), CAST('2025-12-31' AS DATE)),
    c.City,
    DATEADD(DAY, (n.n * 13) % 1000, CAST('2023-01-01' AS DATE)),
    CASE n.n % 5
        WHEN 0 THEN N'No Insurance'
        WHEN 1 THEN N'HealthPlus'
        WHEN 2 THEN N'MediCare'
        WHEN 3 THEN N'LifeShield'
        ELSE N'CareFirst'
    END
FROM Numbers n
JOIN FirstNames fn ON fn.n = ((n.n - 1) % 20) + 1
JOIN LastNames ln ON ln.n = ((n.n * 7 - 1) % 20) + 1
JOIN Cities c ON c.n = ((n.n * 3 - 1) % 10) + 1;
GO

/* Reusable patient-age view (same patient data as the original version) */
CREATE VIEW dbo.VW_PATIENT_AGE
AS
SELECT
    PatientID,
    FirstName,
    LastName,
    Gender,
    DateOfBirth,
    City,
    RegistrationDate,
    InsuranceProvider,
    DATEDIFF(YEAR, DateOfBirth, GETDATE())
      - CASE
          WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateOfBirth, GETDATE()), DateOfBirth) > GETDATE()
          THEN 1 ELSE 0
        END AS Age
FROM dbo.Patients;
GO

/*==============================================================
  5. APPOINTMENTS: 6,000 appointments (2023-2025)
     V2 improvement: varied doctor workload, appointment types,
     and doctor-level status rates. Patient data is unchanged.
==============================================================*/

;WITH Numbers AS
(
    SELECT TOP (6000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Appointments
    (PatientID,DoctorID,AppointmentDate,AppointmentType,Status,Reason)
SELECT
    ((n.n * 37 - 1) % 1000) + 1,
    assigned.DoctorID,
    DATEADD
    (
        MINUTE,
        (n.n % 20) * 30,
        CAST(DATEADD(DAY, (n.n * 7) % 1095, CAST('2023-01-01' AS DATE)) AS DATETIME2(0))
    ),
    CASE WHEN typeBucket.TypeBucket < 55 THEN N'Consultation'
         WHEN typeBucket.TypeBucket < 85 THEN N'Follow-up'
         ELSE N'Emergency' END,
    CASE
        WHEN statusBucket.StatusBucket < rates.CompletionLimit THEN N'Completed'
        WHEN statusBucket.StatusBucket < rates.CompletionLimit + rates.CancellationLimit THEN N'Cancelled'
        WHEN statusBucket.StatusBucket < rates.CompletionLimit + rates.CancellationLimit + rates.NoShowLimit THEN N'No-show'
        ELSE N'Scheduled'
    END,
    CASE n.n % 8
        WHEN 0 THEN N'Routine check-up'
        WHEN 1 THEN N'Headache'
        WHEN 2 THEN N'Skin concern'
        WHEN 3 THEN N'Joint pain'
        WHEN 4 THEN N'Heart check'
        WHEN 5 THEN N'Vision problem'
        WHEN 6 THEN N'Dental pain'
        ELSE N'Child wellness'
    END
FROM Numbers n
CROSS APPLY
(
    SELECT CONVERT(INT, ABS(CONVERT(BIGINT, CHECKSUM(CONCAT(n.n, '|doctor-v2')))) % 1000) AS DoctorBucket
) doctorBucket
CROSS APPLY
(
    SELECT CASE
        WHEN doctorBucket.DoctorBucket < 51 THEN 1
        WHEN doctorBucket.DoctorBucket < 97 THEN 2
        WHEN doctorBucket.DoctorBucket < 138 THEN 3
        WHEN doctorBucket.DoctorBucket < 175 THEN 4
        WHEN doctorBucket.DoctorBucket < 207 THEN 5
        WHEN doctorBucket.DoctorBucket < 235 THEN 6
        WHEN doctorBucket.DoctorBucket < 276 THEN 7
        WHEN doctorBucket.DoctorBucket < 313 THEN 8
        WHEN doctorBucket.DoctorBucket < 348 THEN 9
        WHEN doctorBucket.DoctorBucket < 380 THEN 10
        WHEN doctorBucket.DoctorBucket < 409 THEN 11
        WHEN doctorBucket.DoctorBucket < 437 THEN 12
        WHEN doctorBucket.DoctorBucket < 476 THEN 13
        WHEN doctorBucket.DoctorBucket < 511 THEN 14
        WHEN doctorBucket.DoctorBucket < 543 THEN 15
        WHEN doctorBucket.DoctorBucket < 572 THEN 16
        WHEN doctorBucket.DoctorBucket < 609 THEN 17
        WHEN doctorBucket.DoctorBucket < 642 THEN 18
        WHEN doctorBucket.DoctorBucket < 673 THEN 19
        WHEN doctorBucket.DoctorBucket < 702 THEN 20
        WHEN doctorBucket.DoctorBucket < 730 THEN 21
        WHEN doctorBucket.DoctorBucket < 756 THEN 22
        WHEN doctorBucket.DoctorBucket < 780 THEN 23
        WHEN doctorBucket.DoctorBucket < 802 THEN 24
        WHEN doctorBucket.DoctorBucket < 833 THEN 25
        WHEN doctorBucket.DoctorBucket < 862 THEN 26
        WHEN doctorBucket.DoctorBucket < 890 THEN 27
        WHEN doctorBucket.DoctorBucket < 916 THEN 28
        WHEN doctorBucket.DoctorBucket < 940 THEN 29
        WHEN doctorBucket.DoctorBucket < 962 THEN 30
        WHEN doctorBucket.DoctorBucket < 982 THEN 31
        ELSE 32
    END AS DoctorID
) assigned
CROSS APPLY
(
    SELECT CONVERT(INT, ABS(CONVERT(BIGINT, CHECKSUM(CONCAT(n.n, '|', assigned.DoctorID, '|status-v2')))) % 100) AS StatusBucket
) statusBucket
CROSS APPLY
(
    SELECT
        CASE assigned.DoctorID % 4 WHEN 0 THEN 45 WHEN 1 THEN 50 WHEN 2 THEN 55 ELSE 60 END AS CompletionLimit,
        CASE assigned.DoctorID % 3 WHEN 0 THEN 15 WHEN 1 THEN 19 ELSE 23 END AS CancellationLimit,
        CASE assigned.DoctorID % 3 WHEN 0 THEN 5 WHEN 1 THEN 8 ELSE 11 END AS NoShowLimit
) rates
CROSS APPLY
(
    SELECT CONVERT(INT, ABS(CONVERT(BIGINT, CHECKSUM(CONCAT(n.n, '|type-v2')))) % 100) AS TypeBucket
) typeBucket;
GO

/*==============================================================
  6. TREATMENTS: treatment records for completed appointments
==============================================================*/

;WITH CompletedAppointments AS
(
    SELECT AppointmentID
    FROM dbo.Appointments
    WHERE Status = N'Completed'
),
TreatmentRows AS
(
    SELECT
        AppointmentID,
        ROW_NUMBER() OVER (ORDER BY AppointmentID) AS rn
    FROM CompletedAppointments
)
INSERT INTO dbo.Treatments
    (AppointmentID,TreatmentName,TreatmentCategory,TreatmentCost)
SELECT
    AppointmentID,
    CASE rn % 8
        WHEN 0 THEN N'Blood Test'
        WHEN 1 THEN N'ECG'
        WHEN 2 THEN N'X-Ray'
        WHEN 3 THEN N'Ultrasound'
        WHEN 4 THEN N'Physical Therapy'
        WHEN 5 THEN N'Dental Cleaning'
        WHEN 6 THEN N'Eye Examination'
        ELSE N'Medication'
    END,
    CASE rn % 4
        WHEN 0 THEN N'Diagnostic'
        WHEN 1 THEN N'Imaging'
        WHEN 2 THEN N'Therapeutic'
        ELSE N'Preventive'
    END,
    CAST(150 + (rn * 29 % 1850) AS DECIMAL(10,2))
FROM TreatmentRows
WHERE rn % 4 <> 0; -- approximately 75% of completed appointments receive a treatment
GO

/*==============================================================
  7. BILLS: one bill for each completed appointment
==============================================================*/

;WITH Completed AS
(
    SELECT
        a.AppointmentID,
        CAST(a.AppointmentDate AS DATE) AS BillDate,
        d.ConsultationFee,
        COALESCE(SUM(t.TreatmentCost),0) AS TreatmentAmount
    FROM dbo.Appointments a
    INNER JOIN dbo.Doctors d ON a.DoctorID = d.DoctorID
    LEFT JOIN dbo.Treatments t ON a.AppointmentID = t.AppointmentID
    WHERE a.Status = N'Completed'
    GROUP BY a.AppointmentID, CAST(a.AppointmentDate AS DATE), d.ConsultationFee
),
BillValues AS
(
    SELECT
        *,
        CAST(CASE WHEN AppointmentID % 10 = 0
                  THEN (ConsultationFee + TreatmentAmount) * 0.10
                  ELSE 0 END AS DECIMAL(10,2)) AS DiscountAmount,
        CASE
            WHEN ABS(CONVERT(BIGINT, CHECKSUM(CONCAT(AppointmentID, '|payment-v2')))) % 100 < 64 THEN N'Paid'
            WHEN ABS(CONVERT(BIGINT, CHECKSUM(CONCAT(AppointmentID, '|payment-v2')))) % 100 < 88 THEN N'Partially Paid'
            ELSE N'Unpaid'
        END AS PaymentStatus
    FROM Completed
)
INSERT INTO dbo.Bills
    (AppointmentID,BillDate,ConsultationAmount,TreatmentAmount,
     DiscountAmount,PaymentStatus,PaymentMethod,AmountPaid)
SELECT
    AppointmentID,
    BillDate,
    ConsultationFee,
    TreatmentAmount,
    DiscountAmount,
    PaymentStatus,
    CASE
        WHEN PaymentStatus = N'Unpaid' THEN NULL
        WHEN AppointmentID % 3 = 0 THEN N'Cash'
        WHEN AppointmentID % 3 = 1 THEN N'Card'
        ELSE N'Insurance'
    END,
    CAST
    (
        CASE
            WHEN PaymentStatus = N'Paid'
                THEN ConsultationFee + TreatmentAmount - DiscountAmount
            WHEN PaymentStatus = N'Partially Paid'
                THEN (ConsultationFee + TreatmentAmount - DiscountAmount)
                     * (0.35 + (AppointmentID % 5) * 0.10)
            ELSE 0
        END AS DECIMAL(10,2)
    )
FROM BillValues;
GO

/*==============================================================
  8. VALIDATION: check that data was inserted correctly
==============================================================*/

SELECT 'Departments' AS TableName, COUNT(*) AS TotalRows FROM dbo.Departments
UNION ALL
SELECT 'Doctors', COUNT(*) FROM dbo.Doctors
UNION ALL
SELECT 'Patients', COUNT(*) FROM dbo.Patients
UNION ALL
SELECT 'Appointments', COUNT(*) FROM dbo.Appointments
UNION ALL
SELECT 'Treatments', COUNT(*) FROM dbo.Treatments
UNION ALL
SELECT 'Bills', COUNT(*) FROM dbo.Bills;
GO

/*==============================================================
  9. STARTER QUERIES: run these one at a time after setup
==============================================================*/

-- 1. Preview the patients table
SELECT TOP 10 *
FROM dbo.Patients;

-- 2. Check appointment status distribution
SELECT Status, COUNT(*) AS AppointmentCount
FROM dbo.Appointments
GROUP BY Status
ORDER BY AppointmentCount DESC;

-- 3. Appointments by department
SELECT
    d.DepartmentName,
    COUNT(*) AS TotalAppointments
FROM dbo.Appointments a
INNER JOIN dbo.Doctors doc ON a.DoctorID = doc.DoctorID
INNER JOIN dbo.Departments d ON doc.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY TotalAppointments DESC;

-- 4. Revenue by month (based on billed amounts)
SELECT
    YEAR(BillDate) AS RevenueYear,
    MONTH(BillDate) AS RevenueMonth,
    SUM(TotalAmount) AS TotalRevenue
FROM dbo.Bills
GROUP BY YEAR(BillDate), MONTH(BillDate)
ORDER BY RevenueYear, RevenueMonth;

-- 5. Doctors ranked by completed appointments
SELECT
    doc.DoctorID,
    CONCAT(doc.FirstName, N' ', doc.LastName) AS DoctorName,
    COUNT(*) AS CompletedAppointments,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS DoctorRank
FROM dbo.Appointments a
INNER JOIN dbo.Doctors doc ON a.DoctorID = doc.DoctorID
WHERE a.Status = N'Completed'
GROUP BY doc.DoctorID, doc.FirstName, doc.LastName
ORDER BY DoctorRank, DoctorName;

-- 6. Patients who have never booked an appointment
SELECT p.PatientID, p.FirstName, p.LastName
FROM dbo.Patients p
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Appointments a
    WHERE a.PatientID = p.PatientID
);

-- 7. Monthly revenue with previous month comparison (LAG)
WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(YEAR(BillDate), MONTH(BillDate), 1) AS RevenueMonth,
        SUM(TotalAmount) AS Revenue
    FROM dbo.Bills
    GROUP BY DATEFROMPARTS(YEAR(BillDate), MONTH(BillDate), 1)
)
SELECT
    RevenueMonth,
    Revenue,
    LAG(Revenue) OVER (ORDER BY RevenueMonth) AS PreviousMonthRevenue,
    Revenue - LAG(Revenue) OVER (ORDER BY RevenueMonth) AS RevenueChange
FROM MonthlyRevenue
ORDER BY RevenueMonth;
GO

/*
IMPORTANT PRACTICE NOTE:
The starter queries are examples, not the finished project.
Try writing your own queries before looking at them.
Use the business questions in the accompanying project brief as your analysis checklist.
*/
