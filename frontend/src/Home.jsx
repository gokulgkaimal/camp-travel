import React, { useEffect, useState } from 'react'
const API = import.meta.env.VITE_API || 'http://localhost:5000'

export default function Home() {
  const [rooms, setRooms] = useState([])
  const [name, setName] = useState('Tent')
  const [cap, setCap] = useState(2)

  const load = async () => {
    const r = await fetch(`${API}/rooms`)
    setRooms(await r.json())
  }
  useEffect(() => { load() }, [])

  const addRoom = async () => {
    await fetch(`${API}/rooms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, capacity: Number(cap) })
    })
    setName('')
    setCap(2)
    load()
  }

  return (
    <div>
      <h2>Rooms</h2>
      <div style={{ display: 'flex', gap: 10, margin: '10px 0' }}>
        <input
          value={name}
          onChange={e => setName(e.target.value)}
          placeholder="Room name"
        />
        <input
          type="number"
          value={cap}
          min="1"
          onChange={e => setCap(e.target.value)}
        />
        <button className="btn" onClick={addRoom}>Add Room</button>
      </div>

      <div>
        {rooms.map(r => (
          <div key={r.id} className="card">
            {r.name} — capacity {r.capacity}
          </div>
        ))}
      </div>
    </div>
  )
}
