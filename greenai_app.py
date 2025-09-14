from flask import Flask, request, jsonify, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt  # Import Bcrypt for password hashing
from sqlalchemy.orm import class_mapper, ColumnProperty
from sqlalchemy.orm.attributes import InstrumentedAttribute
from sqlalchemy import func
from sqlalchemy import text
from sqlalchemy import Integer
import os
from werkzeug.security import generate_password_hash
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from flask_cors import CORS 
import smtplib
import random
import base64
import os
import uuid
from flask_restful import Api
from datetime import datetime, timedelta
from textblob import TextBlob

import pymysql
pymysql.install_as_MySQLdb()

app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://saipavantm:8595@10.109.2.210/greenai'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'saipavan'
bcrypt = Bcrypt(app)

db = SQLAlchemy(app)


class UserDetails(db.Model):
    __tablename__ = 'userdetails'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    mobile = db.Column(db.String(255), nullable=False)
    language = db.Column(db.String(255), nullable=False)
    location = db.Column(db.String(255), nullable=False)
    crops = db.Column(db.String(255), nullable=False)
    land_size = db.Column(db.String(255), nullable=False)

@app.route('/userdetails', methods=['POST'])
def add_userdetails():
    data = request.get_json()
    # Validate data here as needed
    user = UserDetails(
        name = data.get('name'),
        email = data.get('email'),
        mobile = data.get('mobile'),
        language = data.get('language'),
        location = data.get('location'),
        crops = data.get('crops'),
        land_size = data.get('land_size')
    )
    db.session.add(user)
    db.session.commit()
    return jsonify({'message': 'User details added', 'id': user.id}), 201


import random
import smtplib
from flask import Flask, request, jsonify
from threading import Lock

otp_storage = {}
otp_lock = Lock()

# Email configuration - replace with your real credentials
EMAIL_ADDRESS = "tmsaipavan@gmail.com"
EMAIL_PASSWORD = "vpqv vtui orbn gzlv"  # Use your app-specific password

SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587


def generate_otp():
    return str(random.randint(100000, 999999))


def send_email(to_email, otp):
    subject = "Your One-Time OTP Code for Verification"
    email_body = f"""Subject: {subject}

Hi there,

Thank you for choosing to verify your account with us. Below is your one-time password (OTP) to complete the verification process:

Your OTP code: {otp}

This code is valid for the next 10 minutes, so please enter it soon to complete your registration.

If you didn't request this OTP or need any assistance, feel free to contact us at tmsaipavan@gmail.com.

Thank you for your trust, and welcome to GREENAI!

Best regards,
GREENAI Team
tmsaipavan@gmail.com | 9962355558
"""
    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        server.sendmail(EMAIL_ADDRESS, to_email, email_body)
        server.quit()
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False


@app.route("/send_otp", methods=["POST"])
def send_otp():
    try:
        data = request.get_json()
        email = data.get("email")
        if not email:
            return jsonify({"status": "error", "message": "Email is required"}), 400

        otp = generate_otp()
        with otp_lock:
            otp_storage[email] = otp

        if send_email(email, otp):
            return jsonify({"status": "success", "message": "OTP sent successfully"}), 200
        else:
            return jsonify({"status": "error", "message": "Failed to send OTP"}), 500
    except Exception as e:
        print(f"Error in send_otp: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500


@app.route("/verify_otp", methods=["POST"])
def verify_otp():
    try:
        data = request.get_json()
        email = data.get("email")
        user_otp = data.get("otp")

        if not email or not user_otp:
            return jsonify({"status": "error", "message": "Email and OTP are required"}), 400

        with otp_lock:
            stored_otp = otp_storage.get(email)

            if stored_otp and stored_otp == user_otp:
                del otp_storage[email]  # Remove OTP after successful verification
                
                # Add to active table
                existing_active = Active.query.filter_by(email=email).first()
                if not existing_active:
                    new_active = Active(email=email)
                    db.session.add(new_active)
                    db.session.commit()
                
                return jsonify({"status": "success", "message": "OTP verified successfully"}), 200
            else:
                return jsonify({"status": "error", "message": "Invalid OTP"}), 401
    except Exception as e:
        print(f"Error in verify_otp: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500



@app.route("/check_email", methods=["POST"])
def check_email():
    try:
        data = request.get_json()
        email = data.get("email")
        if not email:
            return jsonify({"status": "error", "message": "Email is required"}), 400

        # Query the UserDetails table to check if email exists
        user = UserDetails.query.filter_by(email=email).first()

        if user:
            return jsonify({"status": "success", "message": "Email exists"}), 200
        else:
            return jsonify({"status": "error", "message": "Email not registered"}), 404
    except Exception as e:
        print(f"Error in check_email: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500


class Active(db.Model):
    __tablename__ = 'active'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    email = db.Column(db.String(255), nullable=False)

    def __init__(self, email):
        self.email = email

    def __repr__(self):
        return f'<Active {self.email}>'


@app.route("/add_active", methods=["POST"])
def add_active():
    try:
        data = request.get_json()
        email = data.get("email")
        
        if not email:
            return jsonify({"status": "error", "message": "Email is required"}), 400

        # Check if email already exists in active table
        existing_active = Active.query.filter_by(email=email).first()
        if existing_active:
            return jsonify({"status": "error", "message": "Email already active"}), 409

        # Create new active record
        new_active = Active(email=email)
        db.session.add(new_active)
        db.session.commit()

        return jsonify({"status": "success", "message": "Email added to active successfully"}), 201

    except Exception as e:
        db.session.rollback()
        print(f"Error in add_active: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500



@app.route('/get_active_user_details', methods=['GET'])
def get_active_user_details():
    try:
        # Get the most recent active user (assuming latest entry is current)
        active_user = Active.query.order_by(Active.id.desc()).first()
        
        if not active_user:
            return jsonify({
                'status': 'error',
                'message': 'No active user found'
            }), 404

        # Find user details by email from active table
        user = UserDetails.query.filter_by(email=active_user.email).first()
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User details not found for active user'
            }), 404

        # Return user data
        user_data = {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'mobile': user.mobile,
            'language': user.language,
            'location': user.location,
            'crops': user.crops,
            'land_size': user.land_size
        }

        return jsonify({
            'status': 'success',
            'data': user_data,
            'message': 'User details retrieved successfully'
        }), 200

    except Exception as e:
        print(f"Error fetching user details: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'Internal server error'
        }), 500
    
@app.route('/update_user_profile', methods=['PUT'])
def update_user_profile():
    try:
        # Get the most recent active user
        active_user = Active.query.order_by(Active.id.desc()).first()
        
        if not active_user:
            return jsonify({
                'status': 'error',
                'message': 'No active user found'
            }), 401

        # Get user details by email from active table
        user = UserDetails.query.filter_by(email=active_user.email).first()
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404

        # Get JSON data from request
        data = request.get_json()
        
        if not data:
            return jsonify({
                'status': 'error',
                'message': 'No data provided'
            }), 400

        # Update user fields if provided
        if 'name' in data and data['name']:
            user.name = data['name']
        
        if 'email' in data and data['email']:
            # If email is being changed, update the active table as well
            old_email = user.email
            user.email = data['email']
            
            # Update active table with new email
            active_user.email = data['email']
        
        if 'mobile' in data and data['mobile']:
            user.mobile = data['mobile']
        
        if 'language' in data and data['language']:
            user.language = data['language']
        
        if 'location' in data and data['location']:
            user.location = data['location']  # Current coordinates from Flutter
        
        if 'crops' in data and data['crops']:
            user.crops = data['crops']
        
        if 'land_size' in data and data['land_size']:
            user.land_size = data['land_size']

        # Commit changes to database
        db.session.commit()

        # Return updated user data
        updated_user_data = {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'mobile': user.mobile,
            'language': user.language,
            'location': user.location,
            'crops': user.crops,
            'land_size': user.land_size
        }

        return jsonify({
            'status': 'success',
            'data': updated_user_data,
            'message': 'Profile updated successfully'
        }), 200

    except Exception as e:
        # Rollback in case of error
        db.session.rollback()
        print(f"Error updating user profile: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'Failed to update profile'
        }), 500



from datetime import datetime
import pytz

class ChatMessage(db.Model):
    __tablename__ = 'chat_messages'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(255), nullable=False)
    message = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False, default=lambda: datetime.now(pytz.UTC))

    def __init__(self, name, message):
        self.name = name
        self.message = message
        self.timestamp = datetime.now(pytz.UTC)  # Store in UTC

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'message': self.message,
            'timestamp': self.timestamp.isoformat()  # This will include timezone info
        }

    def __repr__(self):
        return f'<ChatMessage {self.name}: {self.message[:20]}...>'


@app.route("/get_current_user", methods=["GET"])
def get_current_user():
    try:
        # Get the first active user (you can modify this logic based on your needs)
        active_user = Active.query.first()
        
        if not active_user:
            return jsonify({"status": "error", "message": "No active user found"}), 404
        
        # Get user details from userdetails table
        user_details = UserDetails.query.filter_by(email=active_user.email).first()
        
        if not user_details:
            return jsonify({"status": "error", "message": "User details not found"}), 404
        
        return jsonify({
            "status": "success",
            "user": {
                "name": user_details.name,
                "email": user_details.email,
                "mobile": user_details.mobile,
                "language": user_details.language,
                "location": user_details.location,
                "crops": user_details.crops,
                "land_size": user_details.land_size
            }
        }), 200

    except Exception as e:
        print(f"Error in get_current_user: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500

@app.route("/send_message", methods=["POST"])
def send_message():
    try:
        data = request.get_json()
        name = data.get("name")
        message = data.get("message")
        
        if not name or not message:
            return jsonify({"status": "error", "message": "Name and message are required"}), 400

        # Create new chat message
        new_message = ChatMessage(name=name, message=message)
        db.session.add(new_message)
        db.session.commit()

        return jsonify({
            "status": "success", 
            "message": "Message sent successfully",
            "data": new_message.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        print(f"Error in send_message: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500

@app.route("/get_messages", methods=["GET"])
def get_messages():
    try:
        # Get all messages ordered by timestamp
        messages = ChatMessage.query.order_by(ChatMessage.timestamp.asc()).all()
        
        messages_data = [message.to_dict() for message in messages]
        
        return jsonify({
            "status": "success",
            "messages": messages_data
        }), 200

    except Exception as e:
        print(f"Error in get_messages: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500



class Reminder(db.Model):
    __tablename__ = 'reminders'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, nullable=True)  # For multi-user support later
    reminder_type = db.Column(db.String(100), nullable=False)
    crop_type = db.Column(db.String(100), nullable=False)
    date = db.Column(db.Date, nullable=False)
    time = db.Column(db.Time, nullable=False)
    interval_type = db.Column(db.String(50), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'reminder_type': self.reminder_type,
            'crop_type': self.crop_type,
            'date': self.date.isoformat() if self.date else None,
            'time': self.time.strftime('%H:%M') if self.time else None,
            'interval_type': self.interval_type,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    

@app.route('/api/reminders', methods=['POST'])
def create_reminder():
    try:
        data = request.get_json()
        
        # Parse date and time
        reminder_date = datetime.strptime(data['date'], '%d/%m/%Y').date()
        reminder_time = datetime.strptime(data['time'], '%H:%M').time()
        
        # Create new reminder
        reminder = Reminder(
            reminder_type=data['reminder_type'],
            crop_type=data['crop_type'],
            date=reminder_date,
            time=reminder_time,
            interval_type=data['interval_type'],
            user_id=data.get('user_id', 1)  # Default user for now
        )
        
        db.session.add(reminder)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Reminder created successfully',
            'reminder': reminder.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error creating reminder: {str(e)}'
        }), 400

@app.route('/api/reminders', methods=['GET'])
def get_reminders():
    try:
        user_id = request.args.get('user_id', 1)
        
        reminders = Reminder.query.filter_by(
            user_id=user_id,
            is_active=True
        ).order_by(Reminder.date.asc(), Reminder.time.asc()).all()
        
        return jsonify({
            'success': True,
            'reminders': [reminder.to_dict() for reminder in reminders]
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error fetching reminders: {str(e)}'
        }), 400

@app.route('/api/reminders/<int:reminder_id>', methods=['DELETE'])
def delete_reminder(reminder_id):
    try:
        reminder = Reminder.query.get_or_404(reminder_id)
        reminder.is_active = False
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Reminder deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error deleting reminder: {str(e)}'
        }), 400

@app.route('/api/reminders/<int:reminder_id>', methods=['PUT'])
def update_reminder(reminder_id):
    try:
        reminder = Reminder.query.get_or_404(reminder_id)
        data = request.get_json()
        
        # Update fields if provided
        if 'reminder_type' in data:
            reminder.reminder_type = data['reminder_type']
        if 'crop_type' in data:
            reminder.crop_type = data['crop_type']
        if 'date' in data:
            reminder.date = datetime.strptime(data['date'], '%d/%m/%Y').date()
        if 'time' in data:
            reminder.time = datetime.strptime(data['time'], '%H:%M').time()
        if 'interval_type' in data:
            reminder.interval_type = data['interval_type']
        
        reminder.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Reminder updated successfully',
            'reminder': reminder.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': f'Error updating reminder: {str(e)}'
        }), 400
    








if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0',port=5000)