import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '@hooks'

export function ProtectedRoute() {
  const { user, loading } = useAuth()

  if (loading) {
    return <p>Loading session...</p>
  }

  if (!user) {
    return <Navigate to="/" replace />
  }

  return <Outlet />
}

