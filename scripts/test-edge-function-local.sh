#!/usr/bin/env bash

# Script to test edge function locally
# Requires: supabase start (local Supabase instance running)

set -e

echo "🧪 Testing ConsentKeys Edge Function Locally"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Supabase is running locally
if ! supabase status &>/dev/null; then
    echo "⚠️  Local Supabase instance not running"
    echo ""
    echo "Start it with:"
    echo "  supabase start"
    echo ""
    read -p "Start local Supabase now? (y/N): " START_SUPABASE
    if [[ $START_SUPABASE =~ ^[Yy]$ ]]; then
        supabase start
    else
        echo "💡 Start Supabase manually, then run this script again"
        exit 1
    fi
fi

echo "✅ Local Supabase is running"
echo ""

# Get local function URL
LOCAL_URL="http://127.0.0.1:54321/functions/v1/consentkeys-callback"

echo "📡 Function will be available at: $LOCAL_URL"
echo ""
echo "To test the function:"
echo "  1. Start the function server:"
echo "     supabase functions serve consentkeys-callback"
echo ""
echo "  2. In another terminal, test with curl:"
echo "     curl -X OPTIONS $LOCAL_URL"
echo "     curl \"$LOCAL_URL?code=test-code\""
echo ""
echo "  3. Check function logs in the serve terminal"
echo ""
read -p "Start function server now? (y/N): " START_SERVE

if [[ $START_SERVE =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Starting edge function server..."
    echo "   Press Ctrl+C to stop"
    echo ""
    supabase functions serve consentkeys-callback
else
    echo ""
    echo "💡 Run manually with: supabase functions serve consentkeys-callback"
fi

