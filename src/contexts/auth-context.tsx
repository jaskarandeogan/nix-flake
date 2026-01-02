import React, { useEffect, useState } from 'react'
import { supabase } from '../utils/supabase'
import { AuthContext } from './auth-context'
import { consentKeysEnv } from '../config/env'
import type { AuthContextValue, OAuthProvider } from '../types/auth'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<AuthContextValue['session']>(null)
  const [user, setUser] = useState<AuthContextValue['user']>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const getInitialSession = async () => {
      const { data, error } = await supabase.auth.getSession()
      if (error) {
        console.error('Failed to get session', error)
      } else {
        setSession(data.session)
        setUser(data.session?.user ?? null)
      }
      setLoading(false)
    }

    getInitialSession()

    const { data: listener } = supabase.auth.onAuthStateChange((_event, newSession) => {
      setSession(newSession)
      setUser(newSession?.user ?? null)
    })

    return () => listener.subscription.unsubscribe()
  }, [])

  const signInWithProvider = async (provider: OAuthProvider) => {
    if (provider === 'consentkeys') {
      const { authorizeUrl, clientId, redirectUri } = consentKeysEnv

      if (!authorizeUrl || !clientId || !redirectUri) {
        console.error('ConsentKeys env vars missing')
        throw new Error('ConsentKeys env vars missing')
      }

      const url = new URL(authorizeUrl)
      url.searchParams.set('client_id', clientId)
      url.searchParams.set('redirect_uri', redirectUri)
      url.searchParams.set('response_type', 'code')
      url.searchParams.set('scope', 'openid email profile')

      window.location.href = url.toString()
      return
    }

    const { error } = await supabase.auth.signInWithOAuth({
      provider: provider as 'google' | 'github' | 'azure',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    })

    if (error) {
      console.error('OAuth sign-in error', error)
      throw error
    }
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) {
      console.error('Sign-out error', error)
      throw error
    }
  }

  const value: AuthContextValue = {
    user,
    session,
    loading,
    signInWithProvider,
    signOut,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

