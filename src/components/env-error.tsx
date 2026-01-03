import React from 'react'

interface EnvErrorProps {
  missingVars: string[]
}

export function EnvError({ missingVars }: EnvErrorProps) {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      padding: '2rem',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      backgroundColor: '#f8f9fa',
      color: '#212529'
    }}>
      <div style={{
        maxWidth: '600px',
        backgroundColor: 'white',
        padding: '2rem',
        borderRadius: '8px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
      }}>
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⚠️</div>
        <h1 style={{ margin: '0 0 1rem 0', fontSize: '1.5rem', fontWeight: '600' }}>
          Configuration Required
        </h1>
        <p style={{ margin: '0 0 1.5rem 0', color: '#6c757d' }}>
          The following environment variables are missing:
        </p>
        <ul style={{
          margin: '0 0 1.5rem 0',
          paddingLeft: '1.5rem',
          color: '#dc3545'
        }}>
          {missingVars.map((varName) => (
            <li key={varName} style={{ marginBottom: '0.5rem' }}>
              <code style={{
                backgroundColor: '#f8f9fa',
                padding: '0.25rem 0.5rem',
                borderRadius: '4px',
                fontFamily: 'monospace'
              }}>{varName}</code>
            </li>
          ))}
        </ul>
        <div style={{
          backgroundColor: '#e7f3ff',
          padding: '1rem',
          borderRadius: '4px',
          marginBottom: '1.5rem'
        }}>
          <h2 style={{ margin: '0 0 0.5rem 0', fontSize: '1rem', fontWeight: '600' }}>
            How to fix:
          </h2>
          <ol style={{ margin: '0', paddingLeft: '1.5rem' }}>
            <li style={{ marginBottom: '0.5rem' }}>
              Copy <code style={{ backgroundColor: 'white', padding: '0.125rem 0.25rem', borderRadius: '2px' }}>env.example</code> to <code style={{ backgroundColor: 'white', padding: '0.125rem 0.25rem', borderRadius: '2px' }}>.env</code>
            </li>
            <li style={{ marginBottom: '0.5rem' }}>
              Fill in your credentials:
              <ul style={{ marginTop: '0.5rem', paddingLeft: '1.5rem' }}>
                {missingVars.some(v => v.includes('SUPABASE')) && (
                  <>
                    <li style={{ marginBottom: '0.5rem' }}>Get <code>VITE_SUPABASE_URL</code> from: <a href="https://supabase.com/dashboard" target="_blank" rel="noopener noreferrer" style={{ color: '#0066cc' }}>Supabase Dashboard</a> → Your Project → Settings → API</li>
                    <li style={{ marginBottom: '0.5rem' }}>Get <code>VITE_SUPABASE_ANON_KEY</code> from the same location</li>
                  </>
                )}
                {missingVars.some(v => v.includes('CONSENT_KEYS')) && (
                  <>
                    <li style={{ marginBottom: '0.5rem' }}>
                      <code>VITE_CONSENT_KEYS_AUTHORIZE_URL</code>: <code style={{ backgroundColor: 'white', padding: '0.125rem 0.25rem', borderRadius: '2px', fontSize: '0.875rem' }}>https://api.pseudoidc.consentkeys.com/auth</code>
                    </li>
                    <li style={{ marginBottom: '0.5rem' }}>
                      <code>VITE_CONSENT_KEYS_CLIENT_ID</code>: Your ConsentKeys OAuth client ID (from ConsentKeys dashboard)
                    </li>
                    <li style={{ marginBottom: '0.5rem' }}>
                      <code>VITE_CONSENT_KEYS_REDIRECT_URI</code>: <code style={{ backgroundColor: 'white', padding: '0.125rem 0.25rem', borderRadius: '2px', fontSize: '0.875rem' }}>https://YOUR_PROJECT.supabase.co/functions/v1/consentkeys-callback</code>
                      <br />
                      <span style={{ fontSize: '0.875rem', color: '#6c757d' }}>(Replace YOUR_PROJECT with your actual Supabase project ID)</span>
                    </li>
                  </>
                )}
              </ul>
            </li>
            <li>Restart your dev server after updating <code>.env</code></li>
          </ol>
        </div>
        <div style={{
          fontSize: '0.875rem',
          color: '#6c757d',
          fontStyle: 'italic'
        }}>
          💡 Tip: The <code>.env</code> file is gitignored and won't be committed to your repository.
        </div>
      </div>
    </div>
  )
}

