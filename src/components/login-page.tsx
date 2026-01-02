import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '@hooks'
import type { OAuthProvider } from '@/types/auth'

const providers: Array<{ id: OAuthProvider; label: string }> = [
  { id: 'consentkeys', label: 'Continue with ConsentKeys' },
]

export function LoginPage() {
  const { signInWithProvider, loading, user } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    if (!loading && user) {
      navigate('/dashboard', { replace: true })
    }
  }, [loading, user, navigate])

  return (
    <div className="card">
      <h1>Sign in</h1>
      <p>Choose a provider to start a session.</p>
      <div className="login-buttons">
        {providers.map((provider) => (
          <button key={provider.id} onClick={() => signInWithProvider(provider.id)} disabled={loading || !!user}>
            {provider.label}
          </button>
        ))}
      </div>
    </div>
  )
}

