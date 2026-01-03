# Authentication Implementation Guide

This document outlines the step-by-step process of implementing OIDC authentication with ConsentKeys and Supabase in a React + Vite application.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Setup Steps](#setup-steps)
4. [Authentication Flow](#authentication-flow)
5. [Component Structure](#component-structure)
6. [Edge Function Setup](#edge-function-setup)
7. [Configuration](#configuration)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This implementation uses:
- **Frontend**: React 18 + TypeScript + Vite
- **Backend**: Supabase (PostgreSQL + Auth + Edge Functions)
- **Auth Provider**: ConsentKeys (custom OIDC provider)
- **Flow**: Custom OAuth bridge via Supabase Edge Function

The authentication flow bypasses Supabase's built-in OAuth providers and uses a custom Edge Function to handle the OIDC flow with ConsentKeys.

---

## Architecture

```
┌─────────────┐         ┌──────────────────┐         ┌──────────────┐
│   React     │         │  Supabase Edge   │         │ ConsentKeys  │
│   App       │────────▶│     Function     │────────▶│   Provider   │
│             │         │                  │         │              │
└─────────────┘         └──────────────────┘         └──────────────┘
       │                          │                           │
       │                          │                           │
       │                          ▼                           │
       │                  ┌──────────────┐                   │
       │                  │   Supabase   │                   │
       └─────────────────▶│     Auth     │◀──────────────────┘
                          │   Database   │
                          └──────────────┘
```

**Key Components:**
1. **Frontend**: React app with auth context and protected routes
2. **Edge Function**: Handles OAuth callback, token exchange, user creation
3. **Supabase Auth**: Manages user sessions and JWT tokens
4. **ConsentKeys Provider**: OIDC authentication provider

---

## Setup Steps

### Step 1: Install Dependencies

```bash
yarn add @supabase/supabase-js react-router-dom
```

### Step 2: Configure Environment Variables

Create a `.env.local` file (copy from `env.example`):

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_CONSENT_KEYS_AUTHORIZE_URL=https://api.pseudoidc.consentkeys.com/auth
VITE_CONSENT_KEYS_CLIENT_ID=your-client-id
VITE_CONSENT_KEYS_REDIRECT_URI=https://your-project.supabase.co/functions/v1/consentkeys-callback
```

### Step 3: Create Supabase Client

**File**: `src/utils/supabase.ts`

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl ?? '', supabaseAnonKey ?? '')
```

### Step 4: Create Auth Context

**File**: `src/contexts/auth-context.ts` (Context definition)
**File**: `src/contexts/auth-context.tsx` (Provider component)
**File**: `src/hooks/use-auth.ts` (Custom hook)

The auth context:
- Manages user session state
- Provides `signInWithProvider()` method
- Provides `signOut()` method
- Listens for auth state changes
- Handles ConsentKeys OAuth redirect

### Step 5: Create Protected Route Component

**File**: `src/components/protected-route.tsx`

Wraps routes that require authentication. Redirects to login if user is not authenticated.

### Step 6: Create Login Page

**File**: `src/components/login-page.tsx`

- Displays login button for ConsentKeys
- Redirects authenticated users to dashboard
- Disables button during loading

### Step 7: Create Auth Callback Handler

**File**: `src/components/auth-callback.tsx`

Handles the callback after Supabase magic link redirect:
- Extracts `access_token` and `refresh_token` from URL hash
- Sets session using `supabase.auth.setSession()`
- Redirects to dashboard on success

### Step 8: Set Up Routing

**File**: `src/App.tsx`

```typescript
<Routes>
  <Route path="/" element={<LoginPage />} />
  <Route path="/auth/callback" element={<AuthCallback />} />
  <Route element={<ProtectedRoute />}>
    <Route path="/dashboard" element={<Dashboard />} />
  </Route>
</Routes>
```

**File**: `src/main.tsx`

Wrap app with `BrowserRouter` and `AuthProvider`:

```typescript
<BrowserRouter>
  <AuthProvider>
    <App />
  </AuthProvider>
</BrowserRouter>
```

---

## Authentication Flow

### Step-by-Step Flow

1. **User Clicks Login**
   - User clicks "Continue with ConsentKeys" button
   - `signInWithProvider('consentkeys')` is called
   - App builds OAuth URL with:
     - `client_id`
     - `redirect_uri` (Edge Function URL)
     - `response_type=code`
     - `scope=openid email profile`
   - Browser redirects to ConsentKeys authorize endpoint

2. **ConsentKeys Authorization**
   - User authenticates with ConsentKeys
   - ConsentKeys redirects back to Edge Function with authorization code
   - URL: `https://your-project.supabase.co/functions/v1/consentkeys-callback?code=...`

3. **Edge Function Processing**
   - Function receives authorization code
   - Exchanges code for access token from ConsentKeys
   - Fetches user info from ConsentKeys userinfo endpoint
   - Checks if user exists in Supabase (by email)
   - Creates new user if doesn't exist, or uses existing user
   - Generates Supabase magic link with `redirectTo` set to `/auth/callback`
   - Redirects browser to magic link URL

4. **Magic Link Redirect**
   - Supabase processes magic link
   - Sets session cookies in browser
   - Redirects to `http://localhost:5173/auth/callback#access_token=...&refresh_token=...`

5. **Frontend Callback Handler**
   - `AuthCallback` component extracts tokens from URL hash
   - Calls `supabase.auth.setSession()` with tokens
   - Session is established in Supabase client
   - User is redirected to `/dashboard`

6. **Dashboard Access**
   - `ProtectedRoute` checks if user is authenticated
   - If authenticated, renders dashboard
   - If not, redirects to login

---

## Component Structure

### Auth Context (`src/contexts/auth-context.tsx`)

**Responsibilities:**
- Manages global auth state (user, session, loading)
- Initializes session on mount
- Listens for auth state changes
- Provides sign-in and sign-out methods

**Key Methods:**
- `signInWithProvider(provider)`: Initiates OAuth flow
- `signOut()`: Signs out user and clears session

### Protected Route (`src/components/protected-route.tsx`)

**Responsibilities:**
- Wraps routes requiring authentication
- Checks if user is authenticated
- Redirects to login if not authenticated

### Login Page (`src/components/login-page.tsx`)

**Responsibilities:**
- Displays login UI
- Redirects authenticated users to dashboard
- Handles ConsentKeys OAuth initiation

### Auth Callback (`src/components/auth-callback.tsx`)

**Responsibilities:**
- Handles post-authentication redirect
- Extracts tokens from URL hash
- Sets Supabase session
- Redirects to dashboard

---

## Edge Function Setup

### Step 1: Create Edge Function

**Location**: `supabase/functions/consentkeys-callback/index.ts`

### Step 2: Function Code Structure

```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req) => {
  // 1. Extract authorization code from URL
  // 2. Exchange code for access token
  // 3. Fetch user info from provider
  // 4. Create or find user in Supabase
  // 5. Generate magic link
  // 6. Redirect to magic link
})
```

### Step 3: Configure Function

**File**: `supabase/functions/consentkeys-callback/config.toml`

```toml
project_id = "your-project-id"

[functions.consentkeys-callback]
verify_jwt = false
```

**Important**: `verify_jwt = false` is required because ConsentKeys doesn't send JWT tokens.

### Step 4: Set Environment Variables

**Note:** `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are automatically available in Supabase Edge Functions and don't need to be set manually.

In Supabase Dashboard → Edge Functions → Secrets, set only:

- `CONSENT_KEYS_TOKEN_URL`: Token endpoint URL (`https://api.pseudoidc.consentkeys.com/token`)
- `CONSENT_KEYS_USERINFO_URL`: Userinfo endpoint URL (`https://api.pseudoidc.consentkeys.com/userinfo`)
- `CONSENT_KEYS_CLIENT_ID`: OAuth client ID
- `CONSENT_KEYS_CLIENT_SECRET`: OAuth client secret
- `APP_URL`: Frontend callback URL (`http://localhost:5173/auth/callback`)

### Step 5: Deploy Function

```bash
supabase functions deploy consentkeys-callback
```

Or use Supabase Dashboard to deploy.

---

## Configuration

### Frontend Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJ...` |
| `VITE_CONSENT_KEYS_AUTHORIZE_URL` | ConsentKeys auth endpoint | `https://api.pseudoidc.consentkeys.com/auth` |
| `VITE_CONSENT_KEYS_CLIENT_ID` | OAuth client ID | `ck_...` |
| `VITE_CONSENT_KEYS_REDIRECT_URI` | Edge function callback URL | `https://xxx.supabase.co/functions/v1/consentkeys-callback` |

### Edge Function Environment Variables

| Variable | Description | Auto-provided? |
|----------|-------------|----------------|
| `SUPABASE_URL` | Supabase project URL | ✅ Yes (automatic) |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (admin access) | ✅ Yes (automatic) |
| `CONSENT_KEYS_TOKEN_URL` | Token exchange endpoint | ❌ No (set manually) |
| `CONSENT_KEYS_USERINFO_URL` | User info endpoint | ❌ No (set manually) |
| `CONSENT_KEYS_CLIENT_ID` | OAuth client ID | ❌ No (set manually) |
| `CONSENT_KEYS_CLIENT_SECRET` | OAuth client secret | ❌ No (set manually) |
| `APP_URL` | Frontend callback URL | ❌ No (set manually) |

**ConsentKeys OIDC Endpoints:**
- Token: `https://api.pseudoidc.consentkeys.com/token`
- UserInfo: `https://api.pseudoidc.consentkeys.com/userinfo`
- Authorization: `https://api.pseudoidc.consentkeys.com/auth`

---

## Troubleshooting

### Issue: 401 "Missing authorization header"

**Solution**: Ensure `verify_jwt = false` is set in `config.toml` and function is redeployed.

### Issue: Redirects to `/#` instead of `/auth/callback`

**Solution**: 
1. Check `APP_URL` in Edge Function secrets is set to `http://localhost:5173/auth/callback`
2. Verify magic link `redirectTo` parameter in function code

### Issue: "Invalid request: both auth code and code verifier should be non-empty"

**Solution**: This happens when trying to use PKCE flow with magic links. The callback component should extract tokens from hash, not use `exchangeCodeForSession()`.

### Issue: User not found after OAuth

**Solution**:
1. Check Edge Function logs in Supabase Dashboard
2. Verify token exchange is successful
3. Check user creation logic in function
4. Verify email is present in userinfo response

### Issue: CORS errors

**Solution**: 
1. Ensure CORS headers are set in Edge Function
2. Verify redirect URLs are whitelisted in ConsentKeys provider settings
3. Check Site URL in Supabase Dashboard → Authentication → URL Configuration

---

## Key Files Reference

### Frontend Files

- `src/utils/supabase.ts` - Supabase client initialization
- `src/contexts/auth-context.ts` - Auth context definition
- `src/contexts/auth-context.tsx` - Auth provider component
- `src/hooks/use-auth.ts` - Auth hook
- `src/components/protected-route.tsx` - Route protection
- `src/components/login-page.tsx` - Login UI
- `src/components/auth-callback.tsx` - Callback handler
- `src/config/env.ts` - Environment variable helpers
- `src/App.tsx` - Routing configuration
- `src/main.tsx` - App entry point

### Backend Files

- `supabase/functions/consentkeys-callback/index.ts` - Edge Function code
- `supabase/functions/consentkeys-callback/config.toml` - Function configuration

---

## Next Steps

1. **Add Error Handling**: Improve error messages and retry logic
2. **Add Loading States**: Show loading indicators during auth flow
3. **Add Token Refresh**: Implement automatic token refresh
4. **Add User Profile Management**: Allow users to update profile
5. **Add Multiple Providers**: Support additional OAuth providers
6. **Add Session Persistence**: Ensure sessions persist across page refreshes
7. **Add Logout Confirmation**: Confirm before signing out

---

## Summary

This implementation provides a complete OIDC authentication flow using:
- React for frontend UI and state management
- Supabase for user management and session handling
- Edge Functions for OAuth bridge between ConsentKeys and Supabase
- Protected routes for secure page access

The flow is secure, scalable, and follows OAuth 2.0 best practices.

