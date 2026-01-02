import type { Session, User } from '@supabase/supabase-js'

export type OAuthProvider = 'google' | 'github' | 'azure' | 'consentkeys'

export type AuthContextValue = {
  user: User | null
  session: Session | null
  loading: boolean
  signInWithProvider: (provider: OAuthProvider) => Promise<void>
  signOut: () => Promise<void>
}

