/*=========================================================
    🔍 1. BED OCCUPANCY PERCENTAGE
=========================================================*/
CREATE OR ALTER VIEW vw_bed_occupancy AS
SELECT 
    p.gender,
    CAST(
        (COUNT(CASE WHEN f.is_currently_admitted = 1 THEN f.bed_id END) * 1.0) /
        NULLIF(COUNT(f.bed_id), 0) * 100
        AS DECIMAL(10,2)
    ) AS bed_occupancy_percent
FROM dbo.fact_patient_flow AS f
INNER JOIN dbo.dim_patient AS p 
    ON f.patient_sk = p.surrogate_key
GROUP BY p.gender;


/*=========================================================
    🔁 2. BED TURNOVER RATE
=========================================================*/
CREATE OR ALTER VIEW vw_bed_turnover_rate AS
SELECT 
    p.gender,
    CAST(
        COUNT(DISTINCT f.fact_id) * 1.0 /
        NULLIF(COUNT(DISTINCT f.bed_id), 0)
        AS DECIMAL(10,2)
    ) AS bed_turnover_rate
FROM dbo.fact_patient_flow AS f
INNER JOIN dbo.dim_patient AS p 
    ON f.patient_sk = p.surrogate_key
GROUP BY p.gender;


/*=========================================================
    👥 3. TOTAL PATIENTS (CURRENTLY ADMITTED)
=========================================================*/
CREATE OR ALTER VIEW vw_patient_demographics AS
SELECT 
    p.gender,
    COUNT(CASE WHEN f.is_currently_admitted = 1 THEN f.fact_id END) AS total_patients
FROM dbo.fact_patient_flow AS f
INNER JOIN dbo.dim_patient AS p 
    ON f.patient_sk = p.surrogate_key
GROUP BY p.gender;


/*=========================================================
    ⏱️ 4. AVERAGE TREATMENT DURATION (HOURS)
=========================================================*/
CREATE OR ALTER VIEW vw_avg_treatment_duration AS
SELECT 
    d.department,
    p.gender,
    CAST(AVG(CAST(f.length_of_stay_hours AS FLOAT)) AS DECIMAL(10,2)) AS avg_treatment_duration_hours
FROM dbo.fact_patient_flow AS f
INNER JOIN dbo.dim_patient AS p 
    ON f.patient_sk = p.surrogate_key
INNER JOIN dbo.dim_department AS d 
    ON f.department_sk = d.surrogate_key
GROUP BY d.department, p.gender;


/*=========================================================
    📈 5. PATIENT VOLUME TREND (BY DATE)
=========================================================*/
CREATE OR ALTER VIEW vw_patient_volume_trend AS
SELECT 
    f.admission_date,
    p.gender,
    COUNT(DISTINCT f.fact_id) AS total_patient_count
FROM dbo.fact_patient_flow AS f
INNER JOIN dbo.dim_patient AS p 
    ON f.patient_sk = p.surrogate_key
GROUP BY f.admission_date, p.gender;


/*=========================================================
    🏥 6. DEPARTMENT INFLOW (CURRENTLY ADMITTED)
=========================================================*/
CREATE OR ALTER VIEW vw_department_inflow AS
SELECT 
    d.department,
    p.gender,
    COUNT(CASE WHEN f.is_currently_admitted = 1 THEN f.fact_id END) AS current_patient_count
FROM dbo.fact_patient_flow AS f
INNER JOIN dbo.dim_patient AS p 
    ON f.patient_sk = p.surrogate_key
INNER JOIN dbo.dim_department AS d 
    ON f.department_sk = d.surrogate_key
GROUP BY d.department, p.gender;


/*=========================================================
    ⏰ 7. OVERSTAY PATIENTS (LENGTH > 50 HOURS)
=========================================================*/
CREATE OR ALTER VIEW vw_overstay_patients AS
SELECT 
    d.department,
    p.gender,
    COUNT(f.fact_id) AS overstay_patient_count
FROM dbo.fact_patient_flow AS f
INNER JOIN dbo.dim_patient AS p 
    ON f.patient_sk = p.surrogate_key
INNER JOIN dbo.dim_department AS d 
    ON f.department_sk = d.surrogate_key
WHERE f.length_of_stay_hours > 50
GROUP BY d.department, p.gender;
