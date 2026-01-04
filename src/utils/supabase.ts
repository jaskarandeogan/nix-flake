import { createClient, SupabaseClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY

// Check for missing environment variables
const missingVars: string[] = []
if (!supabaseUrl || supabaseUrl === 'your-project-url' || supabaseUrl.includes('your-project') || supabaseUrl.trim() === '') {
  missingVars.push('VITE_SUPABASE_URL')
}
if (!supabaseAnonKey || supabaseAnonKey === 'your-anon-key' || supabaseAnonKey.includes('your-anon') || supabaseAnonKey.trim() === '') {
  missingVars.push('VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY')
}

// Check ConsentKeys environment variables
const consentKeysAuthorizeUrl = import.meta.env.VITE_CONSENT_KEYS_AUTHORIZE_URL
const consentKeysClientId = import.meta.env.VITE_CONSENT_KEYS_CLIENT_ID
const consentKeysRedirectUri = import.meta.env.VITE_CONSENT_KEYS_REDIRECT_URI

if (!consentKeysAuthorizeUrl || consentKeysAuthorizeUrl.includes('your-') || consentKeysAuthorizeUrl.trim() === '') {
  missingVars.push('VITE_CONSENT_KEYS_AUTHORIZE_URL')
}
if (!consentKeysClientId || consentKeysClientId.includes('your-') || consentKeysClientId.trim() === '') {
  missingVars.push('VITE_CONSENT_KEYS_CLIENT_ID')
}
if (!consentKeysRedirectUri || consentKeysRedirectUri.includes('your-') || consentKeysRedirectUri.trim() === '') {
  missingVars.push('VITE_CONSENT_KEYS_REDIRECT_URI')
}

// Export missing vars check for use in components
export const getMissingEnvVars = (): string[] => missingVars
export const hasValidEnvVars = (): boolean => missingVars.length === 0

// Only create client if we have valid environment variables
// This prevents errors when env vars are missing
let supabaseInstance: SupabaseClient | null = null

if (hasValidEnvVars() && supabaseUrl && supabaseAnonKey) {
  supabaseInstance = createClient(supabaseUrl, supabaseAnonKey)
}

// Export supabase client - will be null if env vars are invalid
// Components should check hasValidEnvVars() before using
export const supabase = supabaseInstance

