#!/usr/bin/env bash

set -e

echo "🔵 Setting up Supabase CLI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if already logged in
if supabase projects list &>/dev/null; then
    echo "✅ Already authenticated with Supabase"
    CURRENT_USER=$(supabase projects list 2>&1 | head -1 || echo "")
    echo "   Logged in as: $CURRENT_USER"
else
    echo "🔑 Please log in to Supabase..."
    echo "   This will open your browser for authentication."
    echo ""
    supabase login
    
    if supabase projects list &>/dev/null; then
        echo "✅ Successfully authenticated!"
    else
        echo "❌ Authentication failed. Please try again with: setup-supabase"
        return 1
    fi
fi

echo ""

# Check if project exists in current directory
if [ -f "supabase/.gitignore" ]; then
    echo "📁 Supabase project already initialized in this directory"
    
    # Check if linked
    if [ -f "supabase/.temp/project-ref" ]; then
        PROJECT_REF=$(cat supabase/.temp/project-ref)
        echo "🔗 Linked to project: $PROJECT_REF"
    else
        echo "💡 Not linked to a cloud project yet"
        read -p "   Link to existing cloud project? (y/N): " LINK_NOW
        if [[ $LINK_NOW =~ ^[Yy]$ ]]; then
            supabase link
        fi
    fi
else
    echo "🆕 Initializing new Supabase project..."
    echo ""
    
    supabase init
    
    echo ""
    echo "✅ Local Supabase project initialized!"
    echo ""
    
    # Optional: Link to existing cloud project or create new
    echo "Options:"
    echo "  1. Link to existing cloud project"
    echo "  2. Create new cloud project (opens browser)"
    echo "  3. Skip for now (you can link later)"
    echo ""
    read -p "Choose (1/2/3): " CHOICE
    
    case $CHOICE in
        1)
            supabase link
            ;;
        2)
            echo ""
            echo "🌐 Opening Supabase Dashboard to create a new project..."
            echo "   After creating the project, come back and run: supabase link"
            echo ""
            # Try to open browser (works on macOS and Linux)
            if command -v open &> /dev/null; then
                open "https://supabase.com/dashboard/new"
            elif command -v xdg-open &> /dev/null; then
                xdg-open "https://supabase.com/dashboard/new"
            else
                echo "   Please visit: https://supabase.com/dashboard/new"
            fi
            echo ""
            read -p "Press Enter after you've created the project, then we'll link it..."
            supabase link
            ;;
        *)
            echo "💡 Skipped. Run 'supabase link' later to connect to cloud project"
            ;;
    esac
fi

echo ""

# Set up ConsentKeys edge function
EDGE_FUNCTION_PATH="supabase/functions/consentkeys-callback"
if [ -f "$EDGE_FUNCTION_PATH/index.ts" ]; then
    echo "📦 ConsentKeys edge function already exists"
else
    echo "📦 Setting up ConsentKeys edge function..."
    mkdir -p "$EDGE_FUNCTION_PATH"
    
    # Copy edge function template if it exists in the repo
    if [ -f "supabase/functions/consentkeys-callback/index.ts" ]; then
        echo "✅ Edge function template found"
    else
        echo "⚠️  Edge function template not found in repo"
        echo "   Creating basic structure..."
        # The function should be committed to the repo, but if not, we'll note it
        echo "   Note: Make sure supabase/functions/consentkeys-callback/index.ts exists"
    fi
fi

echo ""

# Ask about setting up edge function secrets
if [ -f "supabase/.temp/project-ref" ]; then
    PROJECT_REF=$(cat supabase/.temp/project-ref)
    echo "🔐 Edge Function Secrets Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To use ConsentKeys authentication, you need to set up edge function secrets."
    echo "These can be set via Supabase Dashboard or CLI."
    echo ""
    read -p "Configure edge function secrets now? (y/N): " SETUP_SECRETS
    
    if [[ $SETUP_SECRETS =~ ^[Yy]$ ]]; then
        echo ""
        echo "Note: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are automatically available"
        echo "      in Supabase Edge Functions, so we'll skip those."
        echo ""
        echo "You'll need the following ConsentKeys values:"
        echo "  • CONSENT_KEYS_TOKEN_URL"
        echo "  • CONSENT_KEYS_USERINFO_URL"
        echo "  • CONSENT_KEYS_CLIENT_ID"
        echo "  • CONSENT_KEYS_CLIENT_SECRET"
        echo "  • APP_URL (your frontend callback URL)"
        echo ""
        
        # Get ConsentKeys URLs (using correct endpoints with https)
        echo "ConsentKeys OIDC Endpoints:"
        read -p "Enter ConsentKeys Token URL (default: https://api.pseudoidc.consentkeys.com/token): " TOKEN_URL
        TOKEN_URL=${TOKEN_URL:-https://api.pseudoidc.consentkeys.com/token}
        supabase secrets set CONSENT_KEYS_TOKEN_URL="$TOKEN_URL" --project-ref "$PROJECT_REF" 2>/dev/null || echo "⚠️  Could not set CONSENT_KEYS_TOKEN_URL via CLI. Set it in Dashboard → Edge Functions → Secrets"
        
        read -p "Enter ConsentKeys UserInfo URL (default: https://api.pseudoidc.consentkeys.com/userinfo): " USERINFO_URL
        USERINFO_URL=${USERINFO_URL:-https://api.pseudoidc.consentkeys.com/userinfo}
        supabase secrets set CONSENT_KEYS_USERINFO_URL="$USERINFO_URL" --project-ref "$PROJECT_REF" 2>/dev/null || echo "⚠️  Could not set CONSENT_KEYS_USERINFO_URL via CLI. Set it in Dashboard → Edge Functions → Secrets"
        
        # Get Client Credentials
        echo ""
        read -p "Enter ConsentKeys Client ID: " CLIENT_ID
        if [ -n "$CLIENT_ID" ]; then
            supabase secrets set CONSENT_KEYS_CLIENT_ID="$CLIENT_ID" --project-ref "$PROJECT_REF" 2>/dev/null || echo "⚠️  Could not set CONSENT_KEYS_CLIENT_ID via CLI"
        fi
        
        read -p "Enter ConsentKeys Client Secret: " CLIENT_SECRET
        if [ -n "$CLIENT_SECRET" ]; then
            supabase secrets set CONSENT_KEYS_CLIENT_SECRET="$CLIENT_SECRET" --project-ref "$PROJECT_REF" 2>/dev/null || echo "⚠️  Could not set CONSENT_KEYS_CLIENT_SECRET via CLI"
        fi
        
        # Get App URL
        echo ""
        read -p "Enter your frontend callback URL (default: http://localhost:5173/auth/callback): " APP_URL
        APP_URL=${APP_URL:-http://localhost:5173/auth/callback}
        supabase secrets set APP_URL="$APP_URL" --project-ref "$PROJECT_REF" 2>/dev/null || echo "⚠️  Could not set APP_URL via CLI"
        
        echo ""
        echo "✅ Secrets configuration complete!"
        echo "   Note: If CLI setting failed, set them manually in:"
        echo "   https://supabase.com/dashboard/project/$PROJECT_REF/settings/functions"
    else
        echo "💡 You can set secrets later via:"
        echo "   • Supabase Dashboard → Edge Functions → Secrets"
        echo "   • Or run: supabase secrets set KEY=value --project-ref $PROJECT_REF"
    fi
    
    echo ""
    
    # Verify edge function before deploying
    if [ -f "$EDGE_FUNCTION_PATH/index.ts" ]; then
        echo ""
        read -p "Verify edge function before deploying? (Y/n): " VERIFY_FUNC
        VERIFY_FUNC=${VERIFY_FUNC:-Y}
        if [[ $VERIFY_FUNC =~ ^[Yy]$ ]]; then
            if [ -f "scripts/verify-edge-function.sh" ]; then
                echo ""
                bash scripts/verify-edge-function.sh
                echo ""
            else
                echo "⚠️  Verification script not found, skipping verification"
            fi
        fi
        
        # Ask about deploying the function (default to yes for better UX)
        read -p "Deploy ConsentKeys edge function now? (Y/n): " DEPLOY_FUNC
        DEPLOY_FUNC=${DEPLOY_FUNC:-Y}
        if [[ $DEPLOY_FUNC =~ ^[Yy]$ ]]; then
            echo ""
            echo "🚀 Deploying edge function with --no-verify-jwt flag..."
            echo "   (JWT verification disabled - required for ConsentKeys OAuth flow)"
            supabase functions deploy consentkeys-callback --no-verify-jwt --project-ref "$PROJECT_REF"
            if [ $? -eq 0 ]; then
                echo "✅ Edge function deployed successfully!"
                echo "   JWT verification is disabled for this function"
            else
                echo "⚠️  Deployment failed. You can deploy manually with:"
                echo "   supabase functions deploy consentkeys-callback --no-verify-jwt --project-ref $PROJECT_REF"
            fi
        else
            echo "💡 To deploy later, run:"
            echo "   supabase functions deploy consentkeys-callback --no-verify-jwt --project-ref $PROJECT_REF"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Supabase setup complete!"
echo ""
echo "Next steps:"
echo "  • Run 'supabase start' to start local database (requires Docker)"
echo "  • Run 'supabase status' to see local credentials"
if [ -f "supabase/.temp/project-ref" ]; then
    PROJECT_REF=$(cat supabase/.temp/project-ref)
    echo "  • Deploy edge function: supabase functions deploy consentkeys-callback --no-verify-jwt --project-ref $PROJECT_REF"
    echo "  • Manage edge functions: https://supabase.com/dashboard/project/$PROJECT_REF/functions"
    echo "  • Set secrets: https://supabase.com/dashboard/project/$PROJECT_REF/settings/functions"
fi
echo "  • Visit https://supabase.com to manage cloud projects"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"