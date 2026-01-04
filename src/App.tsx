import { Route, Routes } from 'react-router-dom'
import { AuthCallback } from '@components/auth-callback'
import { LoginPage } from '@components/login-page'
import { ProtectedRoute } from '@components/protected-route'
import { Dashboard } from '@pages/dashboard'

function App() {
  return (
    <Routes>
      <Route path="/" element={<LoginPage />} />
      <Route path="/auth/callback" element={<AuthCallback />} />
      <Route element={<ProtectedRoute />}>
        <Route path="/dashboard" element={<Dashboard />} />
      </Route>
    </Routes>
  )
}

export default App
