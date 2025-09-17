import React, { useState } from 'react'

export default function Login({ onLogin }) {
  const [name, setName] = useState('')

  return (
    <div>
      <h2>Login</h2>
      <p className="muted">Enter a display name to continue.</p>
      <div style={{ display: 'flex', gap: 10 }}>
        <input
          value={name}
          onChange={e => setName(e.target.value)}
          placeholder="Your name"
        />
        <button className="btn" onClick={() => name && onLogin(name)}>Login</button>
      </div>
    </div>
  )
}

