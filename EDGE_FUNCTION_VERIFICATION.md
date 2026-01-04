# Edge Function Verification Guide

This guide explains how to verify your ConsentKeys edge function before deploying.

## Quick Verification

### 1. Automated Verification Script

Run the verification script to check function structure:

```bash
# From within nix develop:
verify-edge-function

# Or directly:
bash scripts/verify-edge-function.sh
```

This checks:
- ✅ Function file exists
- ✅ Required imports (createClient, serve)
- ✅ All environment variables are used
- ✅ CORS headers configured
- ✅ Config file with `verify_jwt = false`
- ✅ Authorization code handling
- ✅ Magic link generation

## Local Testing

### 2. Test Locally with Supabase CLI

**Prerequisites:** Docker Desktop running

```bash
# 1. Start local Supabase instance
supabase start

# 2. Set local secrets (create .env.local or use CLI)
supabase secrets set CONSENT_KEYS_TOKEN_URL="..." --env-file .env.local
# ... set other secrets

# 3. Serve the function locally
supabase functions serve consentkeys-callback

# Function will be available at:
# http://127.0.0.1:54321/functions/v1/consentkeys-callback
```

**Or use the helper script:**
```bash
bash scripts/test-edge-function-local.sh
```

### 3. Test with curl

Once the function is serving locally:

```bash
# Test CORS preflight
curl -X OPTIONS http://127.0.0.1:54321/functions/v1/consentkeys-callback \
  -H "Origin: http://localhost:5173"

# Test with mock authorization code (will fail but shows function is running)
curl "http://127.0.0.1:54321/functions/v1/consentkeys-callback?code=test-code"
```

## Verification Checklist

Before deploying, verify:

- [ ] Function structure verified (`verify-edge-function`)
- [ ] All environment variables set in Supabase Dashboard
- [ ] Config file has `verify_jwt = false`
- [ ] Function tested locally (optional but recommended)
- [ ] CORS headers present
- [ ] Error handling in place

## Environment Variables Required

**Note:** `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are automatically provided by Supabase and don't need to be set manually.

Set these in Supabase Dashboard → Edge Functions → Secrets:

- `CONSENT_KEYS_TOKEN_URL` - Token exchange endpoint (`https://api.pseudoidc.consentkeys.com/token`)
- `CONSENT_KEYS_USERINFO_URL` - User info endpoint (`https://api.pseudoidc.consentkeys.com/userinfo`)
- `CONSENT_KEYS_CLIENT_ID` - OAuth client ID
- `CONSENT_KEYS_CLIENT_SECRET` - OAuth client secret
- `APP_URL` - Frontend callback URL (e.g., `http://localhost:5173/auth/callback`)

## Deployment Verification

After deploying:

1. **Check function logs:**
   ```bash
   supabase functions logs consentkeys-callback
   ```

2. **Test deployed function:**
   ```bash
   curl "https://YOUR_PROJECT.supabase.co/functions/v1/consentkeys-callback?code=test"
   ```

3. **Monitor in Dashboard:**
   - Go to Supabase Dashboard → Edge Functions → consentkeys-callback
   - Check logs and invocations

## Troubleshooting

### Function not found
- Verify function is deployed: `supabase functions list`
- Check function name matches exactly

### Missing environment variables
- Set secrets via Dashboard or CLI
- Verify with: `supabase secrets list`

### CORS errors
- Check CORS headers in function code
- Verify `Access-Control-Allow-Origin` is set to `*` or your domain

### 401 Unauthorized
- Ensure `verify_jwt = false` in config.toml
- Redeploy function after config changes

## Next Steps

After verification:
1. Deploy: `supabase functions deploy consentkeys-callback`
2. Test with real OAuth flow
3. Monitor logs for errors
4. Update frontend to use deployed function URL

