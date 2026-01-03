#!/usr/bin/env bash

set -e

echo "⚛️  Setting up Frontend Project..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if frontend already exists
if [ -f "package.json" ] || [ -f "next.config.js" ] || [ -f "next.config.ts" ] || [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
    echo "📁 Frontend project already detected in this directory"
    
    if [ -f "package.json" ]; then
        PROJECT_NAME=$(cat package.json | grep -o '"name":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
        echo "   Project: $PROJECT_NAME"
    fi
    
    read -p "   Initialize a new frontend project anyway? (y/N): " INIT_ANYWAY
    if [[ ! $INIT_ANYWAY =~ ^[Yy]$ ]]; then
        echo "💡 Skipped. Using existing frontend project"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit 0
    fi
fi

echo ""
echo "Choose your frontend framework:"
echo "  1. React + Supabase Starter (ConsentKeys template) - Recommended"
echo "  2. Next.js (App Router) - Recommended for Vercel + Supabase"
echo "  3. Next.js (Pages Router)"
echo "  4. Vite + React"
echo "  5. Vite + React + TypeScript"
echo "  6. Skip for now"
echo ""
read -p "Choose (1-6): " FRAMEWORK_CHOICE

case $FRAMEWORK_CHOICE in
    1)
        echo ""
        echo "🚀 Cloning React + Supabase starter code..."
        
        # Check if git is available
        if ! command -v git &> /dev/null; then
            echo "❌ Error: 'git' command not found"
            echo "   Make sure you're running this from 'nix develop' environment"
            exit 1
        fi
        
        # Always clone to temp directory first, then copy files
        TEMP_DIR=$(mktemp -d)
        CLONE_DIR="$TEMP_DIR/react-supabase-starter-code"
        
        echo "   Cloning repository..."
        git clone https://git.consentkeys.com/flowstate/react-supabase-starter-code.git "$CLONE_DIR"
        
        # Check if there are conflicting files
        CONFLICTS=0
        for file in "$CLONE_DIR"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                if [ -f "$filename" ] && [ "$filename" != "package.json" ]; then
                    CONFLICTS=1
                    break
                fi
            fi
        done
        
        if [ $CONFLICTS -eq 1 ]; then
            echo "⚠️  Warning: Some files may be overwritten"
            read -p "   Continue anyway? (y/N): " CONTINUE
            if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
                rm -rf "$TEMP_DIR"
                echo "💡 Skipped."
                exit 0
            fi
        fi
        
        # Copy files to current directory
        echo "   Copying files to current directory..."
        cp -r "$CLONE_DIR"/* . 2>/dev/null || true
        # Copy hidden files (but skip .git)
        for file in "$CLONE_DIR"/.*; do
            if [ -f "$file" ] && [ "$(basename "$file")" != ".git" ] && [ "$(basename "$file")" != "." ] && [ "$(basename "$file")" != ".." ]; then
                cp "$file" . 2>/dev/null || true
            fi
        done
        
        # Clean up temp directory
        rm -rf "$TEMP_DIR"
        
        echo ""
        echo "✅ React + Supabase starter code cloned!"
        ;;
    2)
        echo ""
        echo "🚀 Creating Next.js project with App Router..."
        
        # Check if npx is available (should be via nodejs_20)
        if ! command -v npx &> /dev/null; then
            echo "❌ Error: 'npx' command not found"
            echo "   Make sure you're running this from 'nix develop' environment"
            exit 1
        fi
        
        npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes
        
        echo ""
        echo "✅ Next.js project created!"
        ;;
    3)
        echo ""
        echo "🚀 Creating Next.js project with Pages Router..."
        
        if ! command -v npx &> /dev/null; then
            echo "❌ Error: 'npx' command not found"
            exit 1
        fi
        
        npx create-next-app@latest . --typescript --tailwind --eslint --no-app --src-dir --import-alias "@/*" --yes
        
        echo ""
        echo "✅ Next.js project created!"
        ;;
    4)
        echo ""
        echo "🚀 Creating Vite + React project..."
        
        if ! command -v npx &> /dev/null; then
            echo "❌ Error: 'npx' command not found"
            exit 1
        fi
        
        npx create-vite@latest . --template react --yes
        
        echo ""
        echo "✅ Vite + React project created!"
        ;;
    5)
        echo ""
        echo "🚀 Creating Vite + React + TypeScript project..."
        
        if ! command -v npx &> /dev/null; then
            echo "❌ Error: 'npx' command not found"
            exit 1
        fi
        
        npx create-vite@latest . --template react-ts --yes
        
        echo ""
        echo "✅ Vite + React + TypeScript project created!"
        ;;
    *)
        echo "💡 Skipped. You can create a frontend project later with:"
        echo "   • git clone https://git.consentkeys.com/flowstate/react-supabase-starter-code.git"
        echo "   • npx create-next-app@latest"
        echo "   • npx create-vite@latest"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit 0
        ;;
esac

echo ""

# Note: Dependencies will be installed automatically after setup completes
# This is handled in flake.nix shellHook to ensure yarn is available
if [ -f "package.json" ]; then
    echo "📦 Dependencies will be installed automatically after setup"
    
    # Install Supabase client if not already installed
    if ! grep -q "@supabase/supabase-js" package.json; then
        echo ""
        read -p "Install Supabase client library? (Y/n): " INSTALL_SUPABASE
        INSTALL_SUPABASE=${INSTALL_SUPABASE:-Y}
        
        if [[ $INSTALL_SUPABASE =~ ^[Yy]$ ]]; then
            if command -v yarn &> /dev/null; then
                yarn add @supabase/supabase-js
            elif command -v npm &> /dev/null; then
                npm install @supabase/supabase-js
            else
                echo "⚠️  No package manager found. Install dependencies manually later."
            fi
            echo "✅ Supabase client installed"
        fi
    fi
fi

echo ""

# Create or update .env.example file
# Check if the starter code uses REACT_APP_ prefix (Create React App) or NEXT_PUBLIC_ (Next.js)
ENV_PREFIX="REACT_APP_"
if [ -f "next.config.js" ] || [ -f "next.config.ts" ] || [ -f "next.config.mjs" ]; then
    ENV_PREFIX="NEXT_PUBLIC_"
fi

if [ ! -f ".env.example" ]; then
    echo "📝 Creating .env.example file..."
    cat > .env.example << EOF
# Supabase
${ENV_PREFIX}SUPABASE_URL=your-project-url
${ENV_PREFIX}SUPABASE_ANON_KEY=your-anon-key

# Vercel (optional)
VERCEL_PROJECT_ID=your-project-id
VERCEL_ORG_ID=your-org-id
EOF
    echo "✅ Created .env.example"
elif [ "$FRAMEWORK_CHOICE" = "1" ]; then
    # If using the starter code, check if .env.example needs updating
    if ! grep -q "SUPABASE" .env.example 2>/dev/null; then
        echo "📝 Updating .env.example with Supabase variables..."
        cat >> .env.example << EOF

# Supabase
${ENV_PREFIX}SUPABASE_URL=your-project-url
${ENV_PREFIX}SUPABASE_ANON_KEY=your-anon-key
EOF
    fi
fi

# Check if .env exists, if not suggest creating it
if [ ! -f ".env" ] && [ ! -f ".env.local" ]; then
    if [ -f ".env.example" ]; then
        echo ""
        read -p "Create .env file from .env.example? (y/N): " CREATE_ENV
        if [[ $CREATE_ENV =~ ^[Yy]$ ]]; then
            cp .env.example .env
            echo "✅ Created .env file - remember to fill in your values!"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Frontend setup complete!"
echo ""
echo "Next steps:"
echo "  • Fill in your .env file with Supabase credentials"
if [ "$FRAMEWORK_CHOICE" = "1" ]; then
    echo "  • Check package.json for available scripts (usually 'yarn start' or 'yarn dev')"
else
    echo "  • Run 'yarn dev' to start development server"
fi
echo "  • Run 'vercel dev' to start with Vercel integration"
echo "  • Run 'deploy' to deploy to production"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

