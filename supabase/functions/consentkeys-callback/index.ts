// supabase/functions/consentkeys-callback/index.ts
// @ts-expect-error - Deno types are available at runtime in Supabase Edge Functions
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
// @ts-expect-error - Deno std library is available at runtime
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

// Deno is available in Supabase Edge Functions runtime
declare const Deno: {
  env: {
    get(key: string): string | undefined
  }
}

const TOKEN_URL = Deno.env.get('CONSENT_KEYS_TOKEN_URL')!
const USER_INFO_URL = Deno.env.get('CONSENT_KEYS_USERINFO_URL')!
const CLIENT_ID = Deno.env.get('CONSENT_KEYS_CLIENT_ID')!
const CLIENT_SECRET = Deno.env.get('CONSENT_KEYS_CLIENT_SECRET')!
const APP_URL = Deno.env.get('APP_URL') ?? 'http://localhost:5173'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: corsHeaders })

  try {
    const url = new URL(req.url)
    const code = url.searchParams.get('code')
    if (!code) return new Response('Missing code', { status: 400, headers: corsHeaders })

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Build redirect_uri to this function
    const redirectUri = `https://${(Deno.env.get('SUPABASE_URL') ?? '').replace('https://', '')}/functions/v1/consentkeys-callback`

    // 1) Exchange code for token
    const tokenRes = await fetch(TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        code,
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        redirect_uri: redirectUri,
        grant_type: 'authorization_code',
      }),
    })
    const tokenData = await tokenRes.json()
    if (!tokenRes.ok) return new Response('Token exchange failed', { status: 500, headers: corsHeaders })

    // 2) Fetch user info
    const userRes = await fetch(USER_INFO_URL, {
      headers: { Authorization: `Bearer ${tokenData.access_token}` },
    })
    const providerUser = await userRes.json()
    if (!userRes.ok) return new Response('Userinfo failed', { status: 500, headers: corsHeaders })

    const email = providerUser.email
    if (!email) return new Response('Email required', { status: 400, headers: corsHeaders })

    // 3) Create or reuse user
    const { data: existingUsers } = await supabaseAdmin.auth.admin.listUsers()
    const existing = existingUsers?.users.find((u) => u.email === email)
    if (!existing) {
      const { error: userError } = await supabaseAdmin.auth.admin.createUser({
        email,
        email_confirm: true,
        user_metadata: {
          provider: 'consentkeys',
          provider_id: providerUser.sub,
          full_name: providerUser.name,
          username: email.split('@')[0] || `user_${providerUser.sub}`,
        },
      })
      if (userError) return new Response('Create user failed', { status: 500, headers: corsHeaders })
    }

    // 4) Magic link to set session
    const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email,
      options: { redirectTo: APP_URL },
    })
    if (linkError || !linkData?.properties?.action_link) {
      return new Response('Magic link failed', { status: 500, headers: corsHeaders })
    }

    return new Response(null, {
      status: 302,
      headers: { Location: linkData.properties.action_link, ...corsHeaders },
    })
  } catch (err) {
    return new Response(`Error: ${err}`, { status: 500, headers: corsHeaders })
  }
})
