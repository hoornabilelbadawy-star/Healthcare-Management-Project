

--What is the earliest and latest appointment date? 

		SELECT
			MAX (APPOINTMENTDATE) LASTEST ,
			MIN(APPOINTMENTDATE) EALIEST 
		FROM APPOINTMENTS 

--What are the different appointment statuses? 

	SELECT DISTINCT  Status 
	FROM Appointments

--What are the different appointment types? 

	SELECT DISTINCT AppointmentType
	FROM Appointments 

--What departments and specialties are available? 

	SELECT DISTINCT DP.DepartmentName , D.Specialty
	FROM Departments DP
	JOIN Doctors D 
	ON DP.DepartmentID = D.DepartmentID
	
	---SIDE NOTE DEPARTMENT AND SPECIALTIES IN THIS DATABASE ARE THE SAME 

--What payment methods and payment statuses are available?

	SELECT DISTINCT  PaymentMethod 
	FROM Bills 
	WHERE PaymentMethod IS NOT NULL 

	SELECT DISTINCT  PaymentStatus
	FROM Bills 

--Which appointment status represents the largest proportion of all appointments?

SELECT * ,
	CAST(STATUS_NUM /TOTAL_STATUS * 100 AS decimal (10,2)) AS PCT
FROM (
	SELECT DISTINCT Status , 
		COUNT (*) OVER (PARTITION BY STATUS ) STATUS_NUM ,
		CAST ( COUNT (*) OVER () AS decimal (10,2)) TOTAL_STATUS 
	FROM Appointments 
	) S
	ORDER BY PCT DESC

--
SELECT
	Status ,
	COUNT(*) AS STATUS_NUM ,
	CAST(CAST(COUNT(*) AS decimal (10,2)) / 
		(SELECT COUNT (*) FROM Appointments) AS decimal(10,2)) * 100 PCT
FROM Appointments
GROUP BY Status
ORDER BY PCT DESC

--

	SELECT  Status , 
		COUNT (*)  STATUS_NUM ,
		CAST (COUNT (*)  AS decimal (10,2)) / 
		SUM(COUNT(*)( OVER () * 100 PCT  
	FROM Appointments 
	GROUP BY Status
	ORDER BY PCT DESC 

            --	Patients

--How many unique patients are registered?  

SELECT COUNT (*) NUM_OF_PATIENT
FROM Patients

SELECT  COUNT (DISTINCT PatientID) NUM_OF_PATIENT
FROM Patients

--How many patients are there in each gender?

SELECT 
	 Gender , COUNT(*) AS NUM_OF_PATIENT 
FROM Patients 
GROUP BY Gender 
ORDER BY NUM_OF_PATIENT DESC 

--What is the distribution of patients across different cities? 
SELECT * , 
	NUM_OF_PATIENT/TOTAL * 100 PCT 
FROM (
	SELECT DISTINCT
		City ,
		COUNT(*) OVER(PARTITION BY CITY)  AS NUM_OF_PATIENT ,
		CAST (COUNT(*) OVER ()  AS decimal (10,1)) TOTAL 
	FROM Patients
	) P
ORDER BY PCT DESC

--Which insurance providers are most commonly used? 

SELECT 
	InsuranceProvider , COUNT(*) AS NUM_OF_INSURANCE  
FROM Patients 
WHERE InsuranceProvider IS NOT NULL 
GROUP BY InsuranceProvider 
ORDER BY NUM_OF_INSURANCE DESC 

--How are patients distributed across age groups? 
CREATE VIEW AGE_DISTRIBUTION AS 
WITH PATIENT_AGE AS 
(
SELECT  
		COUNT (*) AS NUM_OF_PATIENTS,
		DATEDIFF(YEAR, DateOfBirth,GETDATE()) -
		CASE 
			WHEN DATEADD (YEAR,DATEDIFF(YEAR, DateOfBirth,GETDATE()) ,DateOfBirth ) > GETDATE ()
			THEN 1  ELSE 0
		END AS Age 
FROM Patients 
GROUP BY DATEDIFF(YEAR, DateOfBirth,GETDATE()) -
		CASE 
			WHEN DATEADD (YEAR,DATEDIFF(YEAR, DateOfBirth,GETDATE()) ,DateOfBirth ) > GETDATE ()
			THEN 1  ELSE 0
		END
) , 
	AGE_GROUP  AS (
SELECT NUM_OF_PATIENTS , 
	CASE
	WHEN Age < 18 THEN 'UNDER 18'
	WHEN Age BETWEEN 18 AND 30 THEN '18-30'
	WHEN Age BETWEEN 31 AND 40 THEN '31-40'
	WHEN Age BETWEEN 41 AND 60 THEN '41-60'
	ELSE 'OVER 60'
END AS GROUP_AGE
FROM PATIENT_AGE 
) 
SELECT GROUP_AGE ,
	SUM(NUM_OF_PATIENTS) NUM_OF_PATIENTS
FROM AGE_GROUP
GROUP BY GROUP_AGE 
ORDER BY NUM_OF_PATIENTS DESC


--How are patients distributed across age ?

SELECT 
	DATEDIFF(YEAR, DateOfBirth,GETDATE()) -
	CASE 
		WHEN DATEADD (YEAR,DATEDIFF(YEAR, DateOfBirth,GETDATE()) ,DateOfBirth ) > GETDATE ()
		THEN 1  ELSE 0
	END AS Age ,
	COUNT (*) AS NUM_OF_PATIENTS
FROM Patients
GROUP BY DATEDIFF(YEAR, DateOfBirth,GETDATE()) -
	CASE 
		WHEN DATEADD (YEAR,DATEDIFF(YEAR, DateOfBirth,GETDATE()) ,DateOfBirth ) > GETDATE ()
		THEN 1  ELSE 0
	END 
ORDER BY NUM_OF_PATIENTS DESC


--Which age group has the highest number of registered patients? 

SELECT TOP 1 *
FROM AGE_DISTRIBUTION 
ORDER BY NUM_OF_PATIENTS DESC 
 

 -- What is the average age of patients by gender ?
 WITH PATIENT_AGE AS 
 (
 SELECT GENDER ,
	DATEDIFF (YEAR,DateOfBirth , GETDATE()) -
		CASE 
		WHEN DATEADD (YEAR,DATEDIFF(YEAR, DateOfBirth,GETDATE()) ,DateOfBirth ) > GETDATE ()
		THEN 1  ELSE 0
	END AS Age 
 FROM Patients 
 
  ) 
  SELECT GENDER , 
	COUNT(*) NUM_OF_PATIENT ,
	AVG(CAST (Age AS decimal(10,2))) AVG_AGE 
  FROM PATIENT_AGE
  GROUP BY Gender


--- CREATING AGE VIEW 
CREATE VIEW PATIENT_AGE AS 
SELECT
	PatientID ,
	gender , city ,
	DateOfBirth , 
	DATEDIFF (YEAR,DateOfBirth , GETDATE()) -
		CASE 
		WHEN DATEADD (YEAR,DATEDIFF(YEAR, DateOfBirth,GETDATE()) ,DateOfBirth ) > GETDATE ()
		THEN 1  ELSE 0
	END AS Age 
FROM Patients 



		  --Doctors Analysis 
--Q1. How many doctors are registered in the hospital?

SELECT COUNT (*) AS NUM_OF_DOCT,
	COUNT(DISTINCT DoctorID) UNIQUE_
FROM DOCTORS 

--Q2. How are doctors distributed across different departments? 

SELECT 
	D.DepartmentName , COUNT (DC.DoctorID) AS  NUM_OF_DOCT
FROM Doctors DC
LEFT JOIN Departments D 
ON DC.DepartmentID = D.DepartmentID 
GROUP BY D.DepartmentName 
ORDER BY NUM_OF_DOCT DESC 

--Q3. Which department has the highest and lowest number of doctors?

WITH DOCTCOUNT AS 
(SELECT 
	D.DepartmentName , COUNT (DC.DoctorID) AS  NUM_OF_DOCT
FROM Doctors DC
 JOIN Departments D 
ON DC.DepartmentID = D.DepartmentID 
GROUP BY D.DepartmentName 
) , DEP_RANKING AS 
( 
	SELECT * ,
		RANK() OVER (ORDER BY NUM_OF_DOCT DESC) HIGHEST ,
		RANK() OVER (ORDER BY NUM_OF_DOCT ASC) LOWEST
	FROM DOCTCOUNT
)
SELECT * 
FROM DEP_RANKING 
WHERE HIGHEST = 1 OR LOWEST = 1 

--Q4. Which doctors handle the highest number of appointments? 

SELECT TOP 5 
	CONCAT( D.FirstName,' ', D.LastName) FULL_NAME , 
	COUNT(A.AppointmentID) AS NUM_OF_APPIONT 
FROM Appointments A
  JOIN Doctors  D
ON D.DoctorID = A.DoctorID
GROUP BY CONCAT( D.FirstName,' ', D.LastName) ,
	d.DoctorID
ORDER BY NUM_OF_APPIONT DESC

--Q5. What is the appointment completion rate for each doctor? 

SELECT * , CAST( COMPLETED_APPOINTMENT /TOTAL_APPOINTMENT * 100 AS decimal (10,2)) AS COMPLETION_RATE
FROM (
SELECT D.DoctorID,
	CONCAT( D.FirstName,' ', D.LastName) FULL_NAME , 
	CAST (COUNT(A.AppointmentID) AS decimal (10,2)) AS TOTAL_APPOINTMENT, 
	SUM (CASE WHEN  Status = 'COMPLETED' THEN 1 ELSE 0 END ) AS COMPLETED_APPOINTMENT
FROM Doctors D
 JOIN Appointments A 
ON D.DoctorID = A.DoctorID
GROUP BY CONCAT( D.FirstName,' ', D.LastName) ,
	D.DoctorID
	) R 
ORDER BY COMPLETION_RATE DESC
	
--Q6. Which doctors have the highest cancellation and no-show rates?

SELECT * ,  CAST (CANCELLED_APPOINTMENT /TOTAL_APPOINTMENT * 100 AS decimal (10,2)) AS CANCELLED_RATE ,
			CAST (NO_SHOW_APPOINTMENT /TOTAL_APPOINTMENT * 100 AS decimal (10,2)) AS NO_SHOW_RATE
FROM (
SELECT D.DoctorID,
	CONCAT( D.FirstName,' ', D.LastName) FULL_NAME , 
	CAST (COUNT(A.AppointmentID) AS decimal (10,2)) AS TOTAL_APPOINTMENT, 
	SUM (CASE WHEN  Status = 'CANCELLED' THEN 1 ELSE 0 END ) AS CANCELLED_APPOINTMENT ,
	SUM ( CASE WHEN  Status = 'NO-SHOW' THEN 1  ELSE 0 END ) AS NO_SHOW_APPOINTMENT 
FROM Doctors D
 JOIN Appointments A 
ON D.DoctorID = A.DoctorID
GROUP BY CONCAT( D.FirstName,' ', D.LastName) ,
	D.DoctorID
	) R 
ORDER BY CANCELLED_APPOINTMENT DESC

--Q7. Which specialty has the highiest num of appointment 
SELECT 
	D.Specialty,
	COUNT(A.AppointmentID)  AS TOTAL_APPOINTMENT
FROM Doctors D
 JOIN Appointments A 
ON D.DoctorID = A.DoctorID
GROUP BY  D.Specialty
ORDER BY TOTAL_APPOINTMENT DESC


--Which doctors have the highest completion, cancellation and no-show rates? 

SELECT * , CAST( COMPLETED_APPOINTMENT /TOTAL_APPOINTMENT * 100 AS decimal (10,2)) AS COMPLETION_RATE ,
			CAST( CANCELLED_APPOINTMENT /TOTAL_APPOINTMENT * 100 AS decimal (10,2)) AS CANCELLED_RATE ,
			CAST(NO_SHOW_APPOINTMENT /TOTAL_APPOINTMENT * 100 AS  decimal (10,2)) NO_SHOW_RATE
FROM (
SELECT D.DoctorID,
	CONCAT( D.FirstName,' ', D.LastName) FULL_NAME , 
	CAST (COUNT(A.AppointmentID) AS decimal (10,2)) AS TOTAL_APPOINTMENT, 
	SUM (CASE WHEN  Status = 'COMPLETED' THEN 1 ELSE 0 END ) AS COMPLETED_APPOINTMENT ,
	SUM (CASE WHEN  Status = 'CANCELLED' THEN 1 ELSE 0 END ) AS CANCELLED_APPOINTMENT ,
	SUM ( CASE WHEN  Status = 'NO-SHOW' THEN 1  ELSE 0 END ) AS NO_SHOW_APPOINTMENT 
FROM Doctors D
 JOIN Appointments A 
ON D.DoctorID = A.DoctorID
GROUP BY CONCAT( D.FirstName,' ', D.LastName) ,
	D.DoctorID
	) R 
ORDER BY TOTAL_APPOINTMENT DESC


	     	--DEPARTMENT 
-- Which department handle the highiest number of appointment?

--CTE
WITH DEPART_APPIONTMENT AS 
(
SELECT
	   DP.DepartmentID,
	   DP.DepartmentName , 
	   COUNT(A.AppointmentID)  NUM_OF_APPOINTMENT 
FROM Departments DP
JOIN Doctors D 
ON DP.DepartmentID = D.DepartmentID 
JOIN Appointments A
ON A.DoctorID = D.DoctorID
GROUP BY DP.DepartmentID, DP.DepartmentName 
) 
SELECT * , 
	CAST (NUM_OF_APPOINTMENT AS decimal (10,2)) / 
	SUM (NUM_OF_APPOINTMENT) OVER() * 100 PCT 
FROM DEPART_APPIONTMENT
ORDER BY PCT DESC 

--- SUB

SELECT * , NUM_OF_APPOINTMENT / TOTAL *100 PCT 
FROM (
SELECT
	   DP.DepartmentID,
	   DP.DepartmentName , 
	  CAST(COUNT(A.AppointmentID) AS decimal (10,2))  NUM_OF_APPOINTMENT ,
	   SUM((COUNT(A.AppointmentID))) OVER () AS TOTAL 
FROM Departments DP
JOIN Doctors D 
ON DP.DepartmentID = D.DepartmentID 
JOIN Appointments A
ON A.DoctorID = D.DoctorID
GROUP BY DP.DepartmentID, DP.DepartmentName 
) S 
ORDER BY PCT DESC  

--Which department have the highest completion, cancellation and no-show rates?
WITH DEPARTMNET_NUM AS 
(
SELECT	
	 DP.DepartmentID, DP.DepartmentName , 
	 CAST (COUNT(A.AppointmentID)AS DECIMAL (10,2)) AS TOTAL_APPOINTMET ,
	 SUM(CASE WHEN A.Status = 'COMPLETED' THEN 1 ELSE 0 END) AS TOTAL_COMPLETION ,
	 SUM(CASE WHEN A.Status = 'CANCELLED' THEN 1 ELSE 0 END) AS TOTAL_CANCELLATION ,
	 SUM (CASE WHEN A.Status = 'NO-SHOW' THEN 1 ELSE 0 END )  AS TOTAL_NO_SHOW 	
FROM Departments DP
LEFT JOIN  Doctors DC
ON DP.DepartmentID = DC.DepartmentID 
LEFT JOIN Appointments A 
ON DC.DoctorID = A.DoctorID
GROUP BY DP.DepartmentID, DP.DepartmentName 
) 
SELECT * , 
	CAST(TOTAL_COMPLETION / NULLIF (TOTAL_APPOINTMET,0) * 100 AS decimal (10,2)) AS COMPLETION_RATE,
	CAST(TOTAL_CANCELLATION /NULLIF (TOTAL_APPOINTMET,0) * 100 AS decimal (10,2))AS CANCELLATION_RATE ,
	CAST(TOTAL_NO_SHOW / NULLIF (TOTAL_APPOINTMET,0) * 100 AS decimal (10,2)) AS NO_SHOW_RATE 
FROM DEPARTMNET_NUM 
ORDER BY CANCELLATION_RATE DESC 

		-- Treatment Analysis 
-- which treatment typea sre most frequently provided by the hospital?

SELECT * ,
	CAST(NUM_OF_TREAT / TOTAL * 100 AS decimal (10,2)) PCT 
FROM( 
SELECT	DISTINCT 
	TreatmentCategory , 
	COUNT(*) OVER (PARTITION BY TreatmentCategory ) AS NUM_OF_TREAT ,
	CAST(COUNT (*) OVER () AS decimal (10,2)) AS TOTAL 
FROM Treatments 
	)T
ORDER BY PCT DESC  

--Which treatment categories generate the highest total treatment cost?

SELECT * ,
	CAST(NUM_OF_TREAT / TOTAL_TRATMENT * 100 AS decimal (10,2))COUNT_PCT ,
	CAST(TREAT_COST / TOTAL_COST * 100 AS decimal (10,2))TOTAL_PCT 
FROM( 
SELECT	DISTINCT 
	TreatmentCategory , 
	COUNT(*) OVER (PARTITION BY TreatmentCategory ) AS NUM_OF_TREAT ,
	CAST(COUNT (*) OVER () AS decimal (10,2)) AS TOTAL_TRATMENT ,
	SUM(TreatmentCost) OVER (PARTITION BY TreatmentCategory) TREAT_COST ,
	CAST(SUM(TreatmentCost) OVER () AS decimal (10,2))  TOTAL_COST 
FROM Treatments 
	)T
ORDER BY TOTAL_PCT DESC 

		-- Bills Analysis 
--- Total Bills Amount 
SELECT 
	FORMAT(SUM(TotalAmount),'N0') Total_Bills_Amount
FROM Bills

---Total Amount Paid 
SELECT 
	FORMAT(SUM(AmountPaid),'N0') Total_Amount_Paid 
FROM Bills

---Outstanding Balance  
SELECT 
	FORMAT(SUM (TotalAmount - AmountPaid),'N0') Outstanding_Balance
FROM Bills

---UNPAID BALANCE 
SELECT 
	FORMAT(SUM (TotalAmount - AmountPaid),'N0') Unpaid_Balance
FROM Bills
WHERE PaymentStatus = 'UNPAID'
---- PARTIALLY BALANCE 
SELECT 
	FORMAT(SUM (TotalAmount - AmountPaid),'N0')  Partially_Balance
FROM Bills
WHERE PaymentStatus = 'PARTIALLY PAID'

-- Outstanding Balance Contribution by Payment Status
SELECT * ,
	Status_Balance  /Outstanding * 100 PCT 
FROM (
SELECT  distinct 
	PaymentStatus ,
	CAST(SUM (TotalAmount - AmountPaid) OVER () AS decimal(10,2)) Outstanding ,
	SUM (TotalAmount - AmountPaid) OVER (PARTITION BY PaymentStatus) Status_Balance 
FROM Bills
WHERE PaymentStatus in ( 'PARTIALLY PAID' , 'UNPAID')
) S

--What Percentage of Hospital's Bills are Paid ,Partially Paid and Unpaid?
SELECT * , BILLS_NUM / TOTAL_NUM *100 PCT 
FROM( 
SELECT  DISTINCT PaymentStatus ,
	COUNT (*) OVER (PARTITION BY PaymentStatus ) BILLS_NUM ,
	CAST (COUNT(*)  OVER () AS decimal (10,2)) TOTAL_NUM 
FROM Bills
)B
ORDER BY PCT DESC

--Which payment methods generate the highest collected amount, 
--and what percentage does each method contribute to total collections?

SELECT * ,	
	PAYMANT_AMOUNT  / TOTAL_AMOUNT * 100 PCT 
FROM (
SELECT DISTINCT PaymentMethod ,
	SUM(AmountPaid) OVER (PARTITION BY PaymentMethod) AS PAYMANT_AMOUNT ,
	CAST (SUM (AmountPaid) OVER () AS decimal (10,2))  TOTAL_AMOUNT
FROM BILLS
WHERE PaymentMethod IS NOT NULL 
)A
ORDER BY PCT DESC

--Which Hospital Department generate the highiest total billed amount?

SELECT	
	DP.DepartmentID , DP.DepartmentName ,
	SUM(TotalAmount) BILL_AMOUNT 
FROM Bills B
JOIN Appointments A
ON B.AppointmentID = A.AppointmentID 
JOIN Doctors D 
ON A.DoctorID = D.DoctorID 
JOIN Departments DP 
ON D.DepartmentID = DP.DepartmentID 
GROUP BY DP.DepartmentID , DP.DepartmentName
ORDER BY BILL_AMOUNT DESC 

--Average Billed Amount per appiontment by Department 
WITH DEPARTMENT_ANALYSIS AS 
(
	SELECT
		DP.DepartmentID , DP.DepartmentName ,
		COUNT(DISTINCT B.AppointmentID) NUM_OF_APPOINTMENT ,
		SUM(TotalAmount) BILL_AMOUNT 
	FROM Bills B
	JOIN Appointments A
	ON B.AppointmentID = A.AppointmentID 
	JOIN Doctors D 
	ON A.DoctorID = D.DoctorID 
	JOIN Departments DP 
	ON D.DepartmentID = DP.DepartmentID 
	GROUP BY DP.DepartmentID , DP.DepartmentName
) 
SELECT * ,
	CAST(BILL_AMOUNT AS decimal (10,2)) / NUM_OF_APPOINTMENT  AVG_BILLED_AMOUNT
FROM DEPARTMENT_ANALYSIS 
ORDER BY AVG_BILLED_AMOUNT DESC 

--How does the hospital's billed revenue change over time, month by month?
WITH DATE_REV AS (
SELECT   
	YEAR(BillDate) BILL_YEAR ,
	MONTH (BillDate) BILL_MONTH ,
	FORMAT(BillDate , 'yyyy-MMM') MONTH_YEAR ,
	SUM(TotalAmount) REVENUE 
FROM Bills 
GROUP BY YEAR(BillDate),
	MONTH (BillDate) ,
	FORMAT(BillDate , 'yyyy-MMM') 
) , PREV_REVENUE AS 
(
SELECT * , 
	LAG (REVENUE)  OVER (ORDER BY BILL_YEAR ,BILL_MONTH )  PREVIOUS
FROM DATE_REV 
) 
SELECT * ,
	REVENUE - PREVIOUS AS MON_CHANGE ,
	CAST((REVENUE - PREVIOUS) * 100.0 / PREVIOUS AS decimal (10,2)) MOM_CHANGE_PCT 
FROM PREV_REVENUE 