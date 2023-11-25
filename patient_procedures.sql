DELIMITER //

CREATE PROCEDURE get_patient_diagnosis(IN patient_name VARCHAR(255))
BEGIN
    SELECT
        CONCAT(p.first_name, ' ', p.last_name) AS Patient_Name,
        CONCAT(d.first_name, ' ', d.last_name) AS Doctor_Name,
        pd.symptoms,
        pd.tests,
        pd.procedure_desc,
        m.med_number AS Medicine_Name
    FROM
        patient_info p
    JOIN
        patient_diagnosis pd ON p.patient_id = pd.p_id
    JOIN
        doctor_info d ON pd.d_id = d.doctor_id
    LEFT JOIN
        medicines_info m ON pd.med_id = m.med_id
        
    WHERE
        CONCAT(p.first_name, ' ', p.last_name) = patient_name;
END //

DELIMITER ;

select * from patient_info


drop procedure visit_history;


-- Replace 'John Doe' with the actual patient name you want to query
CALL vist_history('soumya g');



DELIMITER //

CREATE PROCEDURE visit_history(IN patient_name VARCHAR(255))
BEGIN
    SELECT
        CONCAT(p.first_name, ' ', p.last_name) AS Patient_Name,
        a.appointment_number AS Appointment_Number,
        a.appointment_type AS Appointment_Type,
        a.appointment_date AS Appointment_Date,
        CONCAT(d.first_name, ' ', d.last_name) AS Doctor_Name,
        pd.symptoms,
        pd.tests,
        pd.procedure_desc,
        rm.medicine_name
    FROM
        patient_info p
    JOIN
        visithistory_info vh ON p.patient_id = vh.patient_id
    JOIN
        appointment_info a ON vh.appointment_id = a.appointment_id
    JOIN
        doctor_info d ON vh.doctor_id = d.doctor_id
    JOIN
        patient_diagnosis pd ON vh.diagnosis_id = pd.p_id
    LEFT JOIN
        (
            SELECT
                patient_id,
                medicine_name,
                GROUP_CONCAT(medicine_id SEPARATOR ',') AS medicine_ids
            FROM
                report_medicines
            GROUP BY
                patient_id, medicine_name
        ) rm ON p.patient_id = rm.patient_id
    WHERE
        CONCAT(p.first_name, ' ', p.last_name) = patient_name;
END //

DELIMITER ;

select * from visithistory_info;

CREATE PROCEDURE get_patient_prescriptions(IN patient_name VARCHAR(255))
BEGIN
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name, rd.symptoms, rd.tests, pres.medicine_name, pres.medicine_cost
FROM patient_info p
JOIN patient_report pr ON p.patient_id = pr.patient_id
JOIN report_diagnosis rd ON pr.report_id = rd.rep_id AND pr.patient_id = rd.pat_id
JOIN prescription pres ON p.patient_id = pres.patient_id
JOIN prescription_medicines pm ON pres.patient_id = pm.patient_id
JOIN medicines_info m ON pm.medicine_id = m.med_id
WHERE CONCAT(p.First_Name, ' ', p.Last_Name) = patient_name;
END //

DELIMITER ;

call get_patient_prescriptions('soumya g');
select * from patient_info;
select * from doctor_info;
select * from patient_report;
select * from report_diagnosis;
select * from Prescription;
select * from prescription_medicines;
select * from medicines_info;
drop procedure get_patient_prescriptions;

INSERT INTO patient_report (patient_id, report_id) VALUES (5, 2);
select * from prescription;
DESCRIBE patient_report;