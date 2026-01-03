# Development Environment Starter

A reproducible development environment using Nix flakes with Supabase, Vercel, and GitHub CLI pre-configured.

## 🚀 Quick Start

### Prerequisites

- Nix with flakes enabled ([Installation guide](https://nixos.org/download.html))
- macOS, Linux, or NixOS
- **Optional:** Docker Desktop (only needed for local Supabase development)

### Usage
```bash
# Clone this repository
git clone <your-repo-url>
cd nix-flake

# Enter development environment (installs all tools automatically)
nix develop
```

On first run, you'll be prompted to set up:
- ✅ Supabase CLI (authentication + project)
- ✅ Vercel CLI (authentication + project)
- ✅ GitHub CLI (authentication + repository)
- ✅ Frontend dependencies (this repo already includes React + Vite + Supabase frontend code)

### Setting Up Environment Variables

After setup, create your `.env` file:
```bash
cp env.example .env
```

Then edit `.env` with your credentials:
- Get Supabase URL and anon key from: https://supabase.com/dashboard → Your Project → Settings → API
- Add your ConsentKeys credentials (if using ConsentKeys auth)

**Important:** Restart your dev server after updating `.env`:
```bash
yarn dev
```

## 🔄 Reproducibility

This environment is **fully reproducible** across machines:

✅ **Reproducible:**
- All development tools (via Nix flake - same versions everywhere)
- Setup automation scripts
- Frontend code structure
- Environment variable templates

⚠️ **User-specific (not committed):**
- `.env` file with your credentials (gitignored)
- Supabase/Vercel/GitHub project links (stored locally)
- Local development preferences

**To reproduce on a new machine:**
1. Clone the repo
2. Run `nix develop` (same tools, same versions)
3. Run setup scripts (same automation)
4. Create `.env` with your credentials
5. Start developing!

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
- `setup-frontend` - Verify frontend setup (dependencies, .env file) (React + Supabase starter, Next.js, or Vite)

### Development Commands
- `supabase-dev` - Start local Supabase instance (requires Docker)
- `supabase-stop` - Stop local Supabase
- `vercel dev` - Start Vercel development server
- `deploy` - Deploy to Vercel production

> **Note:** Docker is only required for local Supabase development. You can use your cloud Supabase project without Docker by connecting via environment variables.

## ⚛️ Frontend

This repository **already includes** a complete React + Vite + TypeScript frontend with:
- ✅ Pre-configured Supabase integration
- ✅ ConsentKeys OAuth authentication flow
- ✅ Protected routes and auth context
- ✅ Environment variable configuration
- ✅ Ready-to-use project structure

The `setup-frontend` command will:
- Check that dependencies are installed
- Help create `.env` file from `.env.example`
- Verify the frontend is ready to use

**Note:** If you want to use a different framework (Next.js, etc.), you can manually initialize it, but the existing React + Vite setup is ready to go.

## 🎯 Use Cases

Perfect for:
- Full-stack apps with Supabase backend
- Next.js/React projects deploying to Vercel
- Projects using Kiro, Claude Code, or Cursor
- Team collaboration with reproducible environments

## 🔧 Customization

Edit `flake.nix` to add more tools:
```nix
packages = with pkgs; [
  # Add your tools here
  python3
  postgresql
  redis
];
```

## 📝 Environment Variables

The `setup-frontend` command creates a `.env.example` file. Create a `.env` file with your project-specific variables:
```bash
# Supabase (for Vite/React, use VITE_ prefix)
VITE_SUPABASE_URL=your-project-url
VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY=your-anon-key

# For Next.js, use NEXT_PUBLIC_ prefix instead
# NEXT_PUBLIC_SUPABASE_URL=your-project-url
# NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY=your-anon-key

# Vercel (optional)
VERCEL_PROJECT_ID=your-project-id
VERCEL_ORG_ID=your-org-id
```

## 🤝 Contributing

Feel free to submit issues and PRs!

## 📄 License

MIT
