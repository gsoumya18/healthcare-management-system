DELIMITER //

CREATE PROCEDURE InsertAppointment(
    IN p_appointment_id INT,
    IN p_appointment_number VARCHAR(255),
    IN p_appointment_type VARCHAR(255),
    IN p_appointment_date DATE,
    IN p_created_date DATE,
    IN p_doctor_id INT,
    IN p_description VARCHAR(255)
)
BEGIN
    INSERT INTO Appointment_info (
        appointment_id,
        appointment_number,
        appointment_type,
        appointment_date,
        created_date,
        doctor_id,
        description
    ) VALUES (
        p_appointment_id,
        p_appointment_number,
        p_appointment_type,
        p_appointment_date,
        p_created_date,
        p_doctor_id,
        p_description
    );
END //

DELIMITER ;
drop procedure InsertAppointment;
DELIMITER //
DELIMITER //

CREATE PROCEDURE change_appointment (
    IN p_appointment_number VARCHAR(255),
    IN p_appointment_type VARCHAR(255),
    IN p_appointment_date DATE,
    IN p_created_date DATE,
    IN p_doctor_id INT,
    IN p_description VARCHAR(255)
)
BEGIN
    UPDATE Appointment_info
    SET
        appointment_type = p_appointment_type,
        appointment_date = p_appointment_date,
        created_date = p_created_date,
        doctor_id = p_doctor_id,
        description = p_description
    WHERE appointment_number = p_appointment_number;
END //

DELIMITER ;



SELECT * FROM Appointment_info;

drop procedure if exists change_appointment;
DELIMITER //
CREATE PROCEDURE delete_appointment (IN p_appointment_number varchar(255))
BEGIN
    DELETE FROM Appointment WHERE appointment_number = p_appointment_number;
END //
DELIMITER ;

select * from appointment;

delete from appointment where appointment_number

DELIMITER //
CREATE PROCEDURE view_all_appointments()
BEGIN
    SELECT * FROM Appointment_info;
END //
DELIMITER ;

-- Corrected procedure name in the CALL statement
CALL view_all_appointments();


select * from doctor_info;
DELIMITER //
CREATE PROCEDURE get_appointments_by_doctor(IN doctor_name VARCHAR(255))
BEGIN
    SELECT a.appointment_id, a.appointment_number, a.appointment_type, a.appointment_date, a.created_date, d.First_Name, d.Last_Name, a.description
    FROM Appointment_info a
    JOIN doctor_info d ON a.doctor_id = d.Doctor_id
    WHERE CONCAT(d.First_Name, ' ', d.Last_Name) = doctor_name;
END //
#drop procedure get_appointments_by_doctor;
CALL get_appointments_by_doctor('RM kim');


