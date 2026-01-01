# Development Environment Starter

A reproducible development environment using Nix flakes with Supabase, Vercel, and GitHub CLI pre-configured.

## 🚀 Quick Start

### Prerequisites

- Nix with flakes enabled ([Installation guide](https://nixos.org/download.html))
- macOS, Linux, or NixOS

### Usage
```bash
# Create a new project
mkdir my-app && cd my-app

# Initialize from this template
nix flake init -t github:yourusername/nixos-dev-starter

# Enter development environment
nix develop
```

On first run, you'll be prompted to set up:
- ✅ Supabase CLI (authentication + project)
- ✅ Vercel CLI (authentication + project)
- ✅ GitHub CLI (authentication + repository)

## 📦 What's Included

- **Supabase CLI** - Local database & cloud project management
- **Vercel CLI** - Deployment and preview environments
- **GitHub CLI** - Repository and PR management
- **Node.js 20** - Modern JavaScript runtime
- **Git, jq, curl** - Essential development tools

## 🛠️ Available Commands

After entering the environment with `nix develop`:

### Setup Commands
- `setup-all` - Re-run all setup scripts
- `setup-supabase` - Configure Supabase only
- `setup-vercel` - Configure Vercel only
- `setup-github` - Configure GitHub only

### Development Commands
- `supabase-dev` - Start local Supabase instance
- `supabase-stop` - Stop local Supabase
- `vercel dev` - Start Vercel development server
- `deploy` - Deploy to Vercel production

## 🎯 Use Cases

Perfect for:
- Full-stack apps with Supabase backend
- Next.js/React projects deploying to Vercel
- Projects using Kiro, Claude Code, or Cursor
- Team collaboration with reproducible environments

## 🔧 Customization

Edit `flake.nix` to add more tools:
```nix
buildInputs = with pkgs; [
  # Add your tools here
  python3
  postgresql
  redis
];
```

## 📝 Environment Variables

Create a `.env` file for your project-specific variables:
```bash
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
VERCEL_PROJECT_ID=your-project-id
```

## 🤝 Contributing

Feel free to submit issues and PRs!

## 📄 License

MIT