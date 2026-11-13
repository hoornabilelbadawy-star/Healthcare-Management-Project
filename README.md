Healthcare Management – SQL Data Analysis Project

1. Project Overview

This project focuses on analyzing a Healthcare Management database using Microsoft SQL Server (T-SQL).

The main objective is to explore hospital operations and financial performance, identify meaningful patterns, and translate the results into business insights that can support better decision-making.

The analysis covers patient demographics, doctor and department performance, appointment activity, treatment distribution and costs, and hospital billing and collections.

Tools: Microsoft SQL Server Management Studio (SSMS)
SQL Language: T-SQL
Dataset Period: 2023–2025

⸻

2. Database Structure

The database contains six main tables:

Table	Description
Patients	Patient demographic and registration information
Doctors	Doctor information and specialties
Departments	Hospital departments
Appointments	Patient appointments and their statuses
Treatments	Treatments provided and their costs
Bills	Billing amounts, payments, and payment statuses

Table Relationships

The analysis uses the relationships between the tables to connect operational and financial information.

* Departments → Doctors
* Doctors → Appointments
* Patients → Appointments
* Appointments → Treatments
* Appointments → Bills

These relationships allow the analysis to move beyond individual tables and examine performance across different hospital areas.

⸻

3. SQL Skills and Techniques Applied

The project applies SQL concepts to answer practical business questions.

Data Exploration

* Inspecting table structures and available values.
* Identifying distinct appointment statuses, appointment types, specialties, and payment methods.
* Exploring the date range of the available data.

Data Aggregation and Analysis

* GROUP BY
* Aggregate functions: COUNT(), SUM(), and AVG()
* DISTINCT
* CASE WHEN
* Percentage calculations and contribution analysis.

Joins

* INNER JOIN
* LEFT JOIN
* Joining multiple tables to connect appointments, doctors, departments, and bills.

Advanced SQL

* Common Table Expressions (CTEs).
* Subqueries.
* Views.
* Window functions, including:
    * OVER()
    * PARTITION BY
    * ROW_NUMBER(), RANK(), and DENSE_RANK() where ranking is required.
    * LAG() for comparing current and previous periods.

Date and Calculation Functions

* DATEDIFF()
* DATEADD()
* YEAR() and MONTH()
* FORMAT()
* NULLIF()

⸻

4. Analysis and Business Questions

A. Initial Data Exploration

The first step was to understand the database before starting the analysis.

Questions included:

* What is the available appointment date range?
* What appointment statuses and types exist?
* Which departments and specialties are available?
* What payment methods and payment statuses are recorded?
* Which appointment status represents the largest proportion of all appointments?

B. Patients Analysis

The analysis focused on understanding the hospital’s registered patient population.

Business questions:

* How many unique patients are registered?
* How are patients distributed by gender?
* Which cities have the highest number of registered patients?
* Which insurance providers are most commonly used?
* How are patients distributed across age groups?
* Which age group contains the largest number of patients?
* What is the average patient age by gender?

C. Doctors Analysis

This section examined doctor distribution and appointment performance.

Business questions:

* How many doctors are registered?
* How are doctors distributed across departments?
* Which departments have the highest and lowest number of doctors?
* Which doctors handle the highest number of appointments?
* What is the appointment completion rate for each doctor?
* Which doctors have the highest cancellation and no-show rates?
* Which specialties handle the highest number of appointments?

D. Departments Analysis

This section focused on comparing hospital departments through appointment activity and performance.

Business questions:

* Which departments handle the highest number of appointments?
* What percentage of total appointments does each department contribute?
* Which departments have the highest completion, cancellation, and no-show rates?

E. Treatments Analysis

The treatment analysis explored the frequency and financial contribution of different treatment categories.

Business questions:

* Which treatment categories are most frequently provided?
* Which treatment categories generate the highest total treatment cost?
* What percentage of total treatments and total treatment costs does each category represent?

F. Bills Analysis

The billing analysis examined the hospital’s financial performance, collections, outstanding balances, and revenue trends.

Business questions:

* What is the total billed amount?
* How much has been collected?
* What is the outstanding balance?
* How much of the outstanding balance comes from unpaid and partially paid bills?
* What percentage of bills are paid, partially paid, and unpaid?
* Which payment methods contribute the most to total collections?
* Which departments generate the highest total billed amount?
* What is the average billed amount per appointment by department?
* How does billed revenue change month by month?
* What are the largest month-over-month percentage increases and decreases?

⸻

5. Views and Reusable Analysis

Views were created to make frequently used calculations reusable and to simplify later analysis.

PATIENT_AGE View

This view calculates each patient’s age using their date of birth. It also retains relevant patient attributes such as gender and city.

It can be reused in different analyses without repeating the age calculation.

AGE_DISTRIBUTION View

This view groups patients into age categories and calculates the number of patients in each group.

It makes the age distribution analysis easier to reuse and allows further queries, such as identifying the age group with the highest patient count.

Using ORDER BY

ORDER BY was used in analysis queries to sort results, such as ranking departments by appointment count or age groups by patient count.

The sorting is applied when retrieving the results. It is not part of the logical definition of a view, because a view does not guarantee a particular output order.

⸻

6. Key Findings

The following findings were identified during the analysis.

Treatments

* Each treatment category contained 804 treatments.
* The treatment count was distributed almost equally across the categories.
* The total treatment cost contribution was also approximately equal, at around 33% per category.
* No single category showed a meaningful lead in treatment volume or total cost.

Bills and Financial Performance

Metric	Result
Total billed amount	4,393,278
Total amount collected	3,414,765
Outstanding balance	978,513
Collection percentage	77.73%
Outstanding percentage	22.27%

Additional findings:

* Unpaid bills contributed approximately 53.3% of the outstanding balance.
* Partially paid bills contributed approximately 46.7%.
* Paid bills represented approximately 65% of all bills, while unpaid bills represented approximately 12%.
* Insurance and cash each contributed approximately 34% of collections, while card payments contributed approximately 31%.
* Cardiology generated the highest total billed amount, approximately 827,077.
* Neurology had the highest average billed amount per appointment, approximately 1,564.58.

Monthly Revenue Trends

* July 2023 recorded the highest monthly billed revenue.
* December 2025 recorded the largest month-over-month percentage increase, at approximately 37.4%.
* November 2025 recorded the largest month-over-month percentage decrease, at approximately 23.5%.

⸻

7. Analytical Approach

The project followed a question-driven approach:

1. Understand the database structure and available data.
2. Identify relevant business questions for each table.
3. Choose the appropriate SQL techniques and calculations.
4. Explore distributions, totals, percentages, rankings, and trends.
5. Interpret the results in a business context.
6. Connect findings across different tables where relevant.

The focus was not simply on writing SQL queries, but on understanding what each result represents and what it can tell us about hospital operations.

⸻

8. Conclusion

This project provided practical experience in using SQL for exploratory data analysis within a healthcare management context.

By analyzing six connected tables, the project explored patient demographics, doctor and department performance, appointment activity, treatment distribution, and financial performance.

It also demonstrated how SQL techniques such as joins, CTEs, views, aggregations, and window functions can be used to answer business questions and extract meaningful insights from relational data.

The overall goal was to move from querying data to understanding what the data tells us about the business.