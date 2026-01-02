import { createContext } from 'react'
import type { AuthContextValue } from '@/types/auth'

export const AuthContext = createContext<AuthContextValue | undefined>(undefined)

// Re-export AuthProvider from the .tsx file
export { AuthProvider } from './auth-context.tsx'

