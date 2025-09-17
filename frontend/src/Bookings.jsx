import React, { useEffect, useState } from 'react'
const API = import.meta.env.VITE_API || 'http://localhost:5000'

export default function Bookings({ user }) {
  const [rooms, setRooms] = useState([])
  const [bookings, setBookings] = useState([])
  const [roomId, setRoomId] = useState('')
  const [nights, setNights] = useState(1)

  const load = async () => {
    const [r1, r2] = await Promise.all([fetch(`${API}/rooms`), fetch(`${API}/bookings`)]);
    setRooms(await r1.json()); setBookings(await r2.json());
  }
  useEffect(()=>{ load() }, [])

  const book = async () => {
    if(!roomId) return
    await fetch(`${API}/bookings`, {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({user: user || 'Guest', room_id:Number(roomId), nights:Number(nights)})
    })
    setNights(1); load()
  }

  const edit = async (id, newNights) => {
    await fetch(`${API}/bookings/${id}`, {
      method:'PUT',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({nights:newNights})
    })
    load()
  }

  const del = async (id) => { 
    await fetch(`${API}/bookings/${id}`, { method:'DELETE' }) 
    load()
  }

  return (
    <div>
      <h2>Bookings</h2>
      <div style={{display:'flex', gap:10, margin:'10px 0'}}>
        <select value={roomId} onChange={e=>setRoomId(e.target.value)}>
          <option value="">Select room</option>
          {rooms.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
        </select>
        <input type="number" min="1" value={nights} onChange={e=>setNights(e.target.value)} />
        <button className="btn" onClick={book}>Book</button>
      </div>

      {bookings.map(b => (
        <div key={b.id} className="card">
          {b.user} → Room #{b.room_id} for <b>{b.nights}</b> night(s)
          <div style={{display:'inline-flex', gap:8, marginLeft:12}}>
            <button className="btn" onClick={()=>edit(b.id, b.nights+1)}>+1 night</button>
            <button className="btn" onClick={()=>del(b.id)}>Delete</button>
          </div>
        </div>
      ))}
    </div>
  )
}

