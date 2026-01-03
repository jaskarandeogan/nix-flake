import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { AuthProvider } from '@contexts/auth-context'
import { EnvError } from './components/env-error'
import { hasValidEnvVars, getMissingEnvVars } from './utils/supabase'
import './index.css'
import App from './App.tsx'

// Check environment variables before rendering app
if (!hasValidEnvVars()) {
  const missingVars = getMissingEnvVars()
  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <EnvError missingVars={missingVars} />
    </StrictMode>,
  )
} else {
  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <BrowserRouter>
        <AuthProvider>
          <App />
        </AuthProvider>
      </BrowserRouter>
    </StrictMode>,
  )
}
