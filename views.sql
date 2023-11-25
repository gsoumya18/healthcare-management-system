----- VIEWS-------------------
/* View 1: displaying the details of all upcoming appointments for each patient.*/
CREATE VIEW upcoming_appointments_view AS
SELECT
    a.appointment_id,
    a.appointment_number,
    a.appointment_type,
    a.appointment_date,
    a.created_date,
    a.description,
    d.doctor_id,
    CONCAT(d.First_Name, ' ', d.Last_Name) AS Doctor_Name
FROM
    Appointment_info a
JOIN
    doctor_info d ON a.doctor_id = d.doctor_id
WHERE
    a.appointment_date > CURDATE();


select * from upcoming_appointments_view;

/* View 2: displays the summary of the doctors appointmnets*/
CREATE VIEW doctor_appointments_summary AS
SELECT
    d.doctor_id,
    CONCAT(d.First_Name, ' ', d.Last_Name) AS Doctor_Name,
    COUNT(a.appointment_id) AS Total_Appointments,
    GROUP_CONCAT(a.appointment_type ORDER BY a.appointment_date) AS Appointment_Types
FROM
    doctor_info d
LEFT JOIN
    Appointment_info a ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id;

select * from doctor_appointments_summary;

/* View 3: * Displays the patient report*/
CREATE VIEW Patient_Report_View AS
SELECT CONCAT(p.first_name, ' ', p.last_name) AS PatientName,
       pr.diagnosis,
       CONCAT(d.first_name, ' ', d.last_name) AS DoctorName,
       d.speciality
FROM patient_info p
JOIN patient_report pr ON p.patient_id = pr.patient_id
JOIN doctor_info d ON pr.doctor_id = d.doctor_id
ORDER BY p.last_name, p.first_name, pr.preference;

select * from Patient_Report_View;

/* View 4: diplays the patient diagnosis medication view*/
CREATE VIEW patient_diagnosis_medication_view AS
SELECT
    p.patient_id,
    CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name,
    pd.p_id AS Diagnosis_ID,
    pd.symptoms,
    pd.tests,
    pd.procedure_desc,
    m.med_id AS Medication_ID,
    m.med_number AS Medication_Number,
    m.mfd_date AS Medication_Manufacture_Date,
    m.exp_date AS Medication_Expiry_Date,
    m.manufacturer AS Medication_Manufacturer,
    m.quantity AS Medication_Quantity,
    m.origin_country AS Medication_Origin_Country,
    CONCAT(d.First_Name, ' ', d.Last_Name) AS Doctor_Name,
    d.speciality AS Doctor_Speciality
FROM
    patient_info p
JOIN
    patient_diagnosis pd ON p.patient_id = pd.p_id
LEFT JOIN
    medicines_info m ON pd.med_id = m.med_id
JOIN
    doctor_info d ON pd.d_id = d.doctor_id;
    
select * from patient_diagnosis_medication_view;

/* View 5*/
CREATE VIEW Patients_Prescription_View AS
SELECT CONCAT(p.first_name, ' ', p.last_name) AS PatientName,
        ps.medicine_name, ps.medicine_cost, ps.medicine_type
FROM patient_info p
JOIN Prescription ps ON p.patient_id = ps.patient_id
ORDER BY PatientName, ps.medicine_name;

select * from Patients_Prescription_View;


-- Triggers--
DELIMITER //

CREATE TRIGGER appointment_insert_audit
AFTER INSERT ON Appointment_info
FOR EACH ROW
BEGIN
  INSERT INTO Audit_Trail (
    tableName,
    method,
    currentUser,
    accessTime,
    recordId,
    fieldName,
    previous_value,
    after_value
  )
  VALUES (
    'Appointment_info',
    'INSERT',
    USER(),
    NOW(),
    NEW.appointment_id,
    '',
    '',
    CONCAT(
        'Appointment Number: ', NEW.appointment_number,
        ', Appointment Type: ', NEW.appointment_type,
        ', Appointment Date: ', DATE_FORMAT(NEW.appointment_date, '%Y-%m-%d'),
        ', Created Date: ', DATE_FORMAT(NEW.created_date, '%Y-%m-%d'),
        ', Doctor ID: ', NEW.doctor_id,
        ', Description: ', NEW.description
    )
  );
END;

//

DELIMITER ;

 
INSERT INTO Appointment_info ( appointment_number, appointment_type, appointment_date, created_date, doctor_id, description) 
VALUES ('APP006', 'Gynic problems', '2023-04-15', '2023-03-25', 1, 'checkup');

select * from Appointment;

select * from patient_details;

select * from Audit_trail;

SHOW TRIGGERS;





-- Indexes --

/*1 index on single column*/
CREATE INDEX idx_patient_lastname ON patient_info (last_name);
/*2 index on multiple columns*/
CREATE INDEX idx_dob_nationality ON patient_info (date_of_birth, nationality);
/*3 This file considers full-text look through on the location segment, which can be valuable for particular kinds of uses*/
CREATE FULLTEXT INDEX idx_address ON patient_info(address);
/* 4 The phone_number column in the patient_info table will only contain one-of-a-kind values thanks to this index:*/
CREATE UNIQUE INDEX idx_unique_phone_number ON patient_info(phone_number);
/*5Queries that use the Last_Name and Specialty columns for filtering or sorting will benefit from this index's improved performance.*/
CREATE INDEX idx_doctor_details ON doctor_info(Last_Name, Speciality);
/*6 This record will work on the presentation of queries that channel arrangements by doctor_id:*/
CREATE INDEX idx_appointment_doctor ON Appointment_info (doctor_id);
/*7* The appointment_date and doctor_id columns of an index named idx_appointmentdate_doctor_id are added to the Appointment table as a result of this. Queries that require filtering based on appointment_date and/or doctor_id, such as finding all appointments for a specific doctor on a particular date, can be sped up with the help of this index. The way the index can be used in queries is determined by the order of the columns in the definition. For this situation, the most particular section (appointment_date) is recorded first, trailed by doctor_id.*/
CREATE INDEX idx_appointmentdate_doctor_id ON Appointment_info (appointment_date, doctor_id);
/*8*This assertion makes a record named idx_appointment_type on the appointment_type segment of the Appointment table.*/
CREATE INDEX idx_appointment_type ON Appointment_info (appointment_type);
/*9*The patient_report table's diagnosis and doctor_id columns serve as the basis for this index. Since it is a multi-column index, it is constructed using multiple table columns. Because it enables the database to quickly locate the relevant rows, this index can be useful for queries that involve filtering or sorting based on both the diagnosis and doctor_id columns. This can improve the performance of these queries.*/
CREATE INDEX idx_patient_report_multi ON patient_report(diagnosis, doctor_id);
/*10* The primary key constraint requires that report_id be unique, which this index can enforce. It can also expedite queries that require finding a particular report by its ID.*/
CREATE UNIQUE INDEX idx_report_id ON patient_report(report_id);


