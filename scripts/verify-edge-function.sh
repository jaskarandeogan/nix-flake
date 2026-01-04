#!/usr/bin/env bash

set -e

echo "🔍 Verifying ConsentKeys Edge Function..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FUNCTION_PATH="supabase/functions/consentkeys-callback"
ERRORS=0

# Check if function exists
if [ ! -f "$FUNCTION_PATH/index.ts" ]; then
    echo "❌ Edge function not found at $FUNCTION_PATH/index.ts"
    exit 1
fi

echo "✅ Edge function file exists"

# Check for required imports
echo ""
echo "Checking imports..."
if ! grep -q "createClient" "$FUNCTION_PATH/index.ts"; then
    echo "❌ Missing createClient import"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ createClient import found"
fi

if ! grep -q "serve" "$FUNCTION_PATH/index.ts"; then
    echo "❌ Missing serve import"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ serve import found"
fi

# Check for required environment variables
echo ""
echo "Checking environment variables..."
REQUIRED_VARS=(
    "CONSENT_KEYS_TOKEN_URL"
    "CONSENT_KEYS_USERINFO_URL"
    "CONSENT_KEYS_CLIENT_ID"
    "CONSENT_KEYS_CLIENT_SECRET"
    "SUPABASE_URL"
    "SUPABASE_SERVICE_ROLE_KEY"
    "APP_URL"
)

for var in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "$var" "$FUNCTION_PATH/index.ts"; then
        echo "❌ Missing environment variable: $var"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ $var found"
    fi
done

# Check for CORS headers
echo ""
echo "Checking CORS configuration..."
if ! grep -q "Access-Control-Allow-Origin" "$FUNCTION_PATH/index.ts"; then
    echo "❌ Missing CORS headers"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ CORS headers found"
fi

# Check for config file
echo ""
echo "Checking configuration..."
if [ ! -f "$FUNCTION_PATH/config.toml" ]; then
    echo "❌ config.toml not found"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ config.toml exists"
    if ! grep -q "verify_jwt = false" "$FUNCTION_PATH/config.toml"; then
        echo "⚠️  Warning: verify_jwt should be false for ConsentKeys"
    else
        echo "✅ verify_jwt = false configured"
    fi
fi

# Check for main flow components
echo ""
echo "Checking function logic..."
if ! grep -q "code" "$FUNCTION_PATH/index.ts"; then
    echo "❌ Missing authorization code handling"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Authorization code handling found"
fi

if ! grep -q "generateLink\|magiclink" "$FUNCTION_PATH/index.ts"; then
    echo "❌ Missing magic link generation"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Magic link generation found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed! Edge function is ready."
    echo ""
    echo "Next steps:"
    echo "  1. Test locally: supabase functions serve consentkeys-callback"
    echo "  2. Set secrets: supabase secrets set KEY=value"
    echo "  3. Deploy: supabase functions deploy consentkeys-callback"
else
    echo "❌ Found $ERRORS error(s). Please fix them before deploying."
    exit 1
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

