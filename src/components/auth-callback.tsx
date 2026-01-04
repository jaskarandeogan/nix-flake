import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '@utils/supabase'

function parseHashTokens() {
  const hash = window.location.hash.startsWith('#') ? window.location.hash.slice(1) : window.location.hash
  const params = new URLSearchParams(hash)
  const access_token = params.get('access_token')
  const refresh_token = params.get('refresh_token')
  return { access_token, refresh_token, raw: hash }
}

export function AuthCallback() {
  const navigate = useNavigate()
  const [status, setStatus] = useState<'working' | 'error'>('working')
  const [message, setMessage] = useState('Finishing sign in...')

  useEffect(() => {
    const handleExchange = async () => {
      if (!supabase) {
        setStatus('error')
        setMessage('Configuration error: Supabase client not initialized. Please check your environment variables.')
        return
      }

      // Magic link flow returns tokens in the hash fragment.
      const { access_token, refresh_token, raw } = parseHashTokens()
      if (!access_token || !refresh_token) {
        console.error('Magic link tokens missing from hash', raw)
      }
      if (access_token && refresh_token) {
        const { error } = await supabase.auth.setSession({ access_token, refresh_token })
        if (error) {
          console.error('Magic link session error', error)
          setStatus('error')
          setMessage('Sign-in failed. Please try again.')
          return
        }
        window.history.replaceState({}, '', '/auth/callback')
        setMessage('Signed in! Redirecting...')
        navigate('/dashboard', { replace: true })
        return
      }

      // No hash tokens -> stop and show error (we are using magic links, not PKCE here)
      setStatus('error')
      setMessage('Sign-in failed. Missing tokens in callback. Please retry.')
    }

    handleExchange()
  }, [navigate])

  return (
    <div className="card">
      <p>{message}</p>
      {status === 'error' && (
        <button onClick={() => navigate('/', { replace: true })}>Back to sign in</button>
      )}
    </div>
  )
}

