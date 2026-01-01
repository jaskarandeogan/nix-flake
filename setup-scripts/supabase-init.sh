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
    echo "  2. Skip for now (you can link later)"
    echo ""
    read -p "Choose (1/2): " CHOICE
    
    case $CHOICE in
        1)
            supabase link
            ;;
        *)
            echo "💡 Skipped. Run 'supabase link' later to connect to cloud project"
            ;;
    esac
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Supabase setup complete!"
echo ""
echo "Next steps:"
echo "  • Run 'supabase start' to start local database"
echo "  • Run 'supabase status' to see local credentials"
echo "  • Visit https://supabase.com to manage cloud projects"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"