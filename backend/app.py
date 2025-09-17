import os
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", "sqlite:///app.db")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
CORS(app, resources={r"/*": {"origins": "*"}})

db = SQLAlchemy(app)

class Room(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    capacity = db.Column(db.Integer, default=2)

class Booking(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user = db.Column(db.String(80), nullable=False)
    nights = db.Column(db.Integer, default=1)
    room_id = db.Column(db.Integer, db.ForeignKey("room.id"), nullable=False)

with app.app_context():
    db.create_all()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/rooms")
def list_rooms():
    rooms = Room.query.all()
    return jsonify([{"id":r.id,"name":r.name,"capacity":r.capacity} for r in rooms])

@app.post("/rooms")
def create_room():
    d = request.get_json()
    r = Room(name=d["name"], capacity=d.get("capacity",2))
    db.session.add(r); db.session.commit()
    return jsonify({"id": r.id}), 201

@app.get("/bookings")
def list_bookings():
    b = Booking.query.all()
    return jsonify([{"id":x.id,"user":x.user,"nights":x.nights,"room_id":x.room_id} for x in b])

@app.post("/bookings")
def create_booking():
    d = request.get_json()
    b = Booking(user=d["user"], room_id=d["room_id"], nights=d.get("nights",1))
    db.session.add(b); db.session.commit()
    return jsonify({"id": b.id}), 201

@app.put("/bookings/<int:bid>")
def edit_booking(bid):
    d = request.get_json()
    b = Booking.query.get_or_404(bid)
    b.nights = d.get("nights", b.nights)
    db.session.commit()
    return jsonify({"id": b.id, "nights": b.nights})

@app.delete("/bookings/<int:bid>")
def delete_booking(bid):
    b = Booking.query.get_or_404(bid)
    db.session.delete(b); db.session.commit()
    return "", 204

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
