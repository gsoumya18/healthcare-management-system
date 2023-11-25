create table users(
	username varchar(8) NOT NULL, 
    password  varchar(8) NOT NULL,
    Role varchar(20) NOT NULL
    );

#drop table Users;
select * from users;
select * from doctor_info;

select * from patient_info;

select * from users;

DELIMITER $$
CREATE PROCEDURE patient_registration(
    IN pat_id int ,
    IN pat_first_name varchar(255),
    IN pat_last_name varchar(255),
    IN pat_address varchar(255),
    IN pat_phone_number varchar(20),
    IN pat_gender varchar(10),
    IN pat_nationality varchar(50),
    IN pat_date_of_birth date,
    IN pat_email_address varchar(255)
)
BEGIN
    INSERT INTO patient_info (
        patient_id,
        first_name,
        last_name,
        address,
        phone_number,
        gender,
        nationality,
        date_of_birth,
        email_address
    ) VALUES (
        pat_id,
        pat_first_name,
        pat_last_name,
        pat_address,
        pat_phone_number,
        pat_gender,
        pat_nationality,
        pat_date_of_birth,
        pat_email_address
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE create_user(
    IN pat_username varchar(8),
    IN pat_password varchar(8),
    IN pat_role varchar(20)
)
BEGIN
    INSERT INTO users (username, password, Role)
    VALUES (pat_username, pat_password, pat_role);
END$$
DELIMITER ;

CALL create_user('admin', 'admin', 'admin');

drop procedure patient_registration;

DELIMITER $$
CREATE PROCEDURE userlogin(
  In pat_username VARCHAR(50),
   IN pat_password VARCHAR(50),
 OUT  role VARCHAR(50) )
BEGIN

  SELECT @role = role
  FROM users
  WHERE username = @pat_username AND password = pat_password;

  -- If the user is not found, set @role to NULL
END$$
DELIMITER;

CALL userlogin('admin', 'admin', @role);



drop procedure userlogin;
DELIMITER //
CREATE PROCEDURE userlogin(IN pat_username VARCHAR(255), IN pat_password VARCHAR(255), OUT pat_role VARCHAR(255))
BEGIN
  SELECT Role INTO pat_role FROM users WHERE username = pat_username AND password = pat_password;
END;

CALL userlogin('gsr', 'gsr', @role);

DELIMITER $$
CREATE PROCEDURE doctor_registration(
    IN doc_id int ,
    IN doc_first_name varchar(255),
    IN doc_last_name varchar(255),
     IN doc_address varchar(255),
    doc_phone_number varchar(255),
   IN doc_email varchar(255),
    doc_speciality varchar(255)
)
BEGIN
    INSERT INTO doctor_info (
        doctor_id,
        first_name,
        last_name,
        address,
        phone_number,
        email_address,
        speciality
    ) VALUES (
        doc_id,
        doc_first_name,
        doc_last_name,
        doc_address,
        doc_phone_number,
        doc_email,
        doc_speciality
    );
END$$
DELIMITER ;

select * from doctor_info;

drop procedure doctor_registration;


CREATE TABLE audit_trail (
  auditId int NOT NULL auto_increment,
  tableName varchar(255) NOT NULL,
  method varchar(10) NOT NULL,
  currentUser varchar(255) NOT NULL,
  accessTime datetime NOT NULL,
  recordId int,
  fieldName varchar(255),
  previous_value varchar(255),
  after_value varchar(255),
  PRIMARY KEY (auditId)
);
