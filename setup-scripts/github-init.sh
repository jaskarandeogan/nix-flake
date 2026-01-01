#!/usr/bin/env bash

set -e

echo "🐙 Setting up GitHub CLI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check authentication
if gh auth status &>/dev/null; then
    CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
    echo "✅ Already authenticated with GitHub"
    echo "   Logged in as: $CURRENT_USER"
else
    echo "🔑 Please log in to GitHub..."
    echo "   This will guide you through authentication."
    echo ""
    gh auth login
    
    if gh auth status &>/dev/null; then
        echo "✅ Successfully authenticated!"
    else
        echo "❌ Authentication failed. Please try again with: setup-github"
        return 1
    fi
fi

echo ""

# Check if git repo exists
if [ -d ".git" ]; then
    echo "📁 Git repository already initialized"
    
    # Check if has remote
    if git remote get-url origin &>/dev/null; then
        REMOTE_URL=$(git remote get-url origin)
        echo "🔗 Remote configured: $REMOTE_URL"
    else
        echo "💡 No remote configured"
        read -p "   Create and link GitHub repository? (y/N): " CREATE_REPO
        if [[ $CREATE_REPO =~ ^[Yy]$ ]]; then
            create_github_repo
        fi
    fi
else
    echo "🆕 No git repository found"
    echo ""
    read -p "Initialize git repository and create GitHub repo? (y/N): " INIT_GIT
    
    if [[ $INIT_GIT =~ ^[Yy]$ ]]; then
        git init
        echo "✅ Git repository initialized"
        echo ""
        create_github_repo
    else
        echo "💡 Skipped. Run 'git init' and 'setup-github' later if needed"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ GitHub setup complete!"
echo ""
echo "Next steps:"
echo "  • Run 'gh repo view --web' to open repo in browser"
echo "  • Run 'gh pr create' to create pull requests"
echo "  • Run 'gh issue create' to create issues"
echo "  • Visit https://github.com to manage repositories"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

create_github_repo() {
    echo ""
    DEFAULT_NAME=$(basename "$PWD")
    read -p "Repository name [$DEFAULT_NAME]: " REPO_NAME
    REPO_NAME=${REPO_NAME:-$DEFAULT_NAME}
    
    read -p "Make private? (y/N): " IS_PRIVATE
    
    VISIBILITY="--public"
    [[ $IS_PRIVATE =~ ^[Yy]$ ]] && VISIBILITY="--private"
    
    echo ""
    echo "Creating GitHub repository: $REPO_NAME $VISIBILITY"
    
    gh repo create "$REPO_NAME" $VISIBILITY --source=. --remote=origin
    
    echo ""
    echo "✅ Repository created!"
    
    # Offer to make initial commit
    if ! git log &>/dev/null; then
        read -p "Create initial commit? (Y/n): " INIT_COMMIT
        if [[ ! $INIT_COMMIT =~ ^[Nn]$ ]]; then
            git add .
            git commit -m "Initial commit"
            git push -u origin main || git push -u origin master
            echo "✅ Initial commit pushed!"
        fi
    fi
}