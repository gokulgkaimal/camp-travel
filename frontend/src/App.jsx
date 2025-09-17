import React, { useState } from 'react'
import { Routes, Route, Link, Navigate } from 'react-router-dom'
import Login from './Login'
import Home from './Home'
import Bookings from './Bookings'

export default function App() {
  const [user, setUser] = useState(localStorage.getItem('user') || '')
  const signOut = () => { localStorage.removeItem('user'); setUser('') }

  return (
    <div className="app-shell">
      <nav className="nav">
        <div>
          <Link to="/">Home</Link>
          <Link to="/bookings">Bookings</Link>
        </div>
        <div>
          {user ? (
            <>
              <span className="muted" style={{marginRight:12}}>Hi, <b>{user}</b></span>
              <button className="btn" onClick={signOut}>Logout</button>
            </>
          ) : <Link to="/login" className="btn">Login</Link>}
        </div>
      </nav>

      <main className="hero">
        <h1>🏕️ Camp & Travel</h1>
        <p className="muted">Find rooms, make bookings, and plan trips — fast.</p>

        <div className="panel">
          <Routes>
            <Route path="/" element={<Home user={user}/>} />
            <Route path="/login" element={<Login onLogin={u => {localStorage.setItem('user', u); setUser(u)}} />} />
            <Route path="/bookings" element={user ? <Bookings user={user}/> : <Navigate to="/login" />} />
          </Routes>
        </div>
      </main>

      <div className="footer">© {new Date().getFullYear()} Camp & Travel</div>
    </div>
  )
}
