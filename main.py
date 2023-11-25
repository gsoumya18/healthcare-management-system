from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="Healthcare Management System", version="1.0.0")

# --- DB Connection ---
def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "G11_emr"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "")
    )

# --- Models ---
class PatientRegister(BaseModel):
    patient_id: int
    first_name: str
    last_name: str
    address: str
    phone_number: str
    gender: str
    nationality: str
    date_of_birth: str
    email_address: str
    username: str
    password: str

class DoctorRegister(BaseModel):
    doctor_id: int
    first_name: str
    last_name: str
    address: str
    phone_number: str
    email_address: str
    speciality: str
    username: str
    password: str

class LoginRequest(BaseModel):
    username: str
    password: str

class AppointmentCreate(BaseModel):
    appointment_id: int
    appointment_number: str
    appointment_type: str
    appointment_date: str
    created_date: str
    doctor_id: int
    description: str
    username: str
    password: str

class AppointmentModify(BaseModel):
    appointment_type: str
    appointment_date: str
    created_date: str
    doctor_id: int
    description: str

# --- Routes ---

@app.get("/")
def root():
    return {"message": "Healthcare Management System API is running!"}

@app.post("/register/patient")
def register_patient(data: PatientRegister):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.callproc('patient_registration', [
            data.patient_id, data.first_name, data.last_name,
            data.address, data.phone_number, data.gender,
            data.nationality, data.date_of_birth, data.email_address
        ])
        cursor.callproc('create_user', [data.username, data.password, "Patient"])
        conn.commit()
        return {"message": f"Patient {data.first_name} {data.last_name} registered successfully!"}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.post("/register/doctor")
def register_doctor(data: DoctorRegister):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.callproc('doctor_registration', [
            data.doctor_id, data.first_name, data.last_name,
            data.address, data.phone_number, data.email_address, data.speciality
        ])
        cursor.callproc('create_user', [data.username, data.password, "Doctor"])
        conn.commit()
        return {"message": f"Doctor {data.first_name} {data.last_name} registered successfully!"}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.post("/login")
def login(data: LoginRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT username, password, role FROM Users WHERE username=%s", [data.username])
        user = cursor.fetchone()
        if user is None or data.password != user[1]:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        return {"message": "Login successful!", "role": user[2]}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.post("/appointments")
def create_appointment(data: AppointmentCreate):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        # Verify role
        cursor.execute("SELECT role FROM Users WHERE username=%s AND password=%s", [data.username, data.password])
        user = cursor.fetchone()
        if not user:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        if user[0] != "Patient":
            raise HTTPException(status_code=403, detail="Only patients can book appointments")
        cursor.callproc('InsertAppointment', [
            data.appointment_id, data.appointment_number, data.appointment_type,
            data.appointment_date, data.created_date, data.doctor_id, data.description
        ])
        conn.commit()
        return {"message": f"Appointment {data.appointment_number} booked successfully!"}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.put("/appointments/{appointment_number}")
def modify_appointment(appointment_number: str, data: AppointmentModify):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.callproc('change_appointment', [
            appointment_number, data.appointment_type,
            data.appointment_date, data.created_date,
            data.doctor_id, data.description
        ])
        conn.commit()
        return {"message": f"Appointment {appointment_number} updated successfully!"}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.get("/appointments")
def view_all_appointments():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('view_all_appointments')
        result = []
        for res in cursor.stored_results():
            result.extend(res.fetchall())
        return {"appointments": result}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.get("/appointments/doctor/{doctor_name}")
def appointments_by_doctor(doctor_name: str):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('get_appointments_by_doctor', [doctor_name])
        result = []
        for res in cursor.stored_results():
            result.extend(res.fetchall())
        return {"doctor": doctor_name, "appointments": result, "total": len(result)}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.get("/patients/{patient_name}/diagnosis")
def patient_diagnosis(patient_name: str):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('get_patient_diagnosis', [patient_name])
        result = []
        for res in cursor.stored_results():
            result.extend(res.fetchall())
        return {"patient": patient_name, "diagnosis": result}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.get("/patients/{patient_name}/history")
def visit_history(patient_name: str):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('visit_history', [patient_name])
        result = []
        for res in cursor.stored_results():
            result.extend(res.fetchall())
        return {"patient": patient_name, "visit_history": result, "total_visits": len(result)}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()

@app.get("/patients/{patient_name}/prescriptions")
def patient_prescriptions(patient_name: str):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.callproc('get_patient_prescriptions', [patient_name])
        result = []
        for res in cursor.stored_results():
            result.extend(res.fetchall())
        return {"patient": patient_name, "prescriptions": result}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()