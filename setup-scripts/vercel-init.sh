#!/usr/bin/env bash

set -e

echo "🔺 Setting up Vercel CLI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check authentication
if vercel whoami &>/dev/null; then
    CURRENT_USER=$(vercel whoami 2>/dev/null)
    echo "✅ Already authenticated with Vercel"
    echo "   Logged in as: $CURRENT_USER"
else
    echo "🔑 Please log in to Vercel..."
    echo "   This will open your browser for authentication."
    echo ""
    vercel login
    
    if vercel whoami &>/dev/null; then
        echo "✅ Successfully authenticated!"
    else
        echo "❌ Authentication failed. Please try again with: setup-vercel"
        return 1
    fi
fi

echo ""

# Check if project exists
if [ -f ".vercel/project.json" ]; then
    echo "📁 Vercel project already linked"
    
    PROJECT_NAME=$(cat .vercel/project.json | grep -o '"name":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
    echo "🔗 Linked to: $PROJECT_NAME"
else
    echo "🆕 Setting up Vercel project..."
    echo ""
    echo "Options:"
    echo "  1. Link to existing Vercel project"
    echo "  2. Create new Vercel project"
    echo "  3. Skip for now"
    echo ""
    read -p "Choose (1/2/3): " CHOICE
    
    case $CHOICE in
        1)
            echo ""
            vercel link
            ;;
        2)
            echo ""
            echo "Creating new project..."
            # Initialize with current directory name as default
            vercel --yes
            ;;
        *)
            echo "💡 Skipped. Run 'vercel link' or 'vercel' later to set up project"
            ;;
    esac
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Vercel setup complete!"
echo ""
echo "Next steps:"
echo "  • Run 'vercel dev' to start development server"
echo "  • Run 'vercel' to deploy to preview"
echo "  • Run 'vercel --prod' to deploy to production"
echo "  • Visit https://vercel.com to manage projects"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"