# Development Environment Starter

A reproducible development environment using Nix flakes with Supabase, Vercel, and GitHub CLI pre-configured. This guide provides step-by-step instructions for setting up the entire development environment.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Step-by-Step Setup Guide](#step-by-step-setup-guide)
  - [Step 0: Create ConsentKeys OAuth Application](#step-0-create-consentkeys-oauth-application)
- [Environment Variables](#environment-variables)
- [Edge Function Configuration](#edge-function-configuration)
- [Available Commands](#available-commands)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:

1. **Git installed** and configured
   - Installation: https://git-scm.com/downloads
   - Verify: `git --version` should work
   - Configure your name and email: `git config --global user.name "Your Name"` and `git config --global user.email "your.email@example.com"`

2. **Supabase account** created beforehand
   - Sign up at: https://supabase.com
   - You'll need this to link or create a project during setup

3. **Vercel account** created beforehand
   - Sign up at: https://vercel.com
   - You'll need this to link or create a project during setup

4. **GitHub account** created beforehand
   - Sign up at: https://github.com
   - You'll need this to link or create a repository during setup

5. **ConsentKeys account** and OAuth application created beforehand
   - Sign up at: https://pseudoidc.consentkeys.com (or your ConsentKeys platform URL)
   - You'll need to create an OAuth application to get your client ID and secret
   - See [Step 0: Create ConsentKeys OAuth Application](#step-0-create-consentkeys-oauth-application) below for detailed instructions

6. **Nix installed** with flakes enabled
   - Installation: https://nixos.org/download.html
   - Verify: `nix --version` should work
   - If `nix` command is not found, add to your `~/.zshrc`:
     ```bash
     # Nix
     export PATH="/nix/var/nix/profiles/default/bin:$PATH"
     if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then 
       . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
     fi
     ```
     Then restart your terminal or run `source ~/.zshrc`

7. **macOS, Linux, or NixOS** operating system

8. **Optional: Docker Desktop** (only needed for local Supabase development)

## Step-by-Step Setup Guide

Follow these steps in order to set up your development environment:

### Step 0: Create ConsentKeys OAuth Application

**⚠️ IMPORTANT:** You must create a ConsentKeys OAuth application **before** running the Supabase setup, as you'll need the client ID and client secret during configuration.

#### Prerequisites

- A ConsentKeys account (sign up if you don't have one)
- Access to the ConsentKeys /Developer Portal from the dashboard

#### Step-by-Step Process

1. **Access the ConsentKeys Platform**
   - Navigate to the ConsentKeys platform in your browser
   - Log in with your ConsentKeys account credentials

2. **Verify Your Session**
   - Once authenticated, ensure you're logged in successfully
   - You should see your dashboard or account page

3. **Access the Developer Portal**
   - Navigate to the Developer Portal section
   - This is typically found in account settings or a dedicated "Developers" section
   - Look for "OAuth Applications" or "Applications" menu

4. **Fill Out the Application Form**

   **Basic Information:**
   - **Application Name:** Choose a descriptive name (e.g., "My App - Development")
   - **Description:** Optional description of your application
   - **Application Type:** Select "OAuth 2.0" or "Web Application"

   **OAuth Configuration:**
   - **Redirect URI(s):** Add your redirect URI(s)
     - For local development: `http://localhost:5173/auth/callback`
     - For production: `https://your-project-id.supabase.co/functions/v1/consentkeys-callback`
     - **Best Practice:** Add separate redirect URIs for each environment (development, staging, production)
   - **Scopes:** Select the OAuth scopes your application needs (typically `openid`, `profile`, `email`)

5. **Create the Application**
   - Review all information for accuracy
   - Click "Create Application" or "Save" button
   - Wait for confirmation that the application was created successfully

6. **Save Your Credentials**

   After successful creation, you'll see:
   - **Client ID:** This will be displayed (starts with `ck_`)
   - **Client Secret:** This will be shown **ONLY ONCE**

   **⚠️ CRITICAL: Save Your Client Secret Immediately**
   
   The client secret will **ONLY be shown once**! You must save it immediately:
   
   - Copy the client secret to a secure password manager
   - Store it in a secure location (not in version control)
   - If you lose it, you'll need to regenerate it (which may invalidate existing integrations)
   
   **Important Security Notes:**
   - Never commit client secrets to git repositories
   - Use environment variables or secret management tools
   - The client secret is used for server-side operations only

7. **Application Status**
   - Verify the application status is "Active" or "Enabled"
   - Note your Client ID for use in configuration

#### What You'll Need Later

After creating the application, you'll need these values for configuration:

- **Client ID** (`CONSENT_KEYS_CLIENT_ID` / `VITE_CONSENT_KEYS_CLIENT_ID`)
  - Format: `ck_xxxxxxxxxxxxx`
  - Used in both frontend and edge function configuration

- **Client Secret** (`CONSENT_KEYS_CLIENT_SECRET`)
  - Format: A long random string
  - Used only in edge function secrets (server-side)
  - **Never expose this in frontend code**

- **Redirect URI**
  - Must match exactly what you configured in ConsentKeys
  - For Supabase edge function: `https://your-project-id.supabase.co/functions/v1/consentkeys-callback`
  - For local development: `http://localhost:5173/auth/callback`

#### Common Pitfalls and Troubleshooting

**Redirect URL Issues:**

**Problem:** Authentication fails with "redirect_uri_mismatch" error

**Solution:**
- Ensure the redirect URI in your ConsentKeys application **exactly matches** the one used in your code
- Check for trailing slashes, `http` vs `https`, and port numbers
- The redirect URI must be one of the URIs you configured in the ConsentKeys application

**Multiple Environments:**

**Best Practice:** Add separate redirect URLs for each environment:
- Development: `http://localhost:5173/auth/callback`
- Staging: `https://staging.yourdomain.com/auth/callback`
- Production: `https://your-project-id.supabase.co/functions/v1/consentkeys-callback`

**Lost Client Secret:**

**Problem:** You forgot to save the client secret

**Solution:**
- Check if you saved it in a password manager or secure notes
- If lost, you may need to regenerate it in the ConsentKeys Developer Portal
- Regenerating may invalidate existing integrations, so update all configurations

#### Integration Checklist

Before proceeding to Supabase setup, verify:

- ✅ ConsentKeys OAuth application created
- ✅ Client ID saved and accessible
- ✅ Client Secret saved securely (not in git)
- ✅ Redirect URI configured correctly
- ✅ Application status is "Active"
- ✅ You have the ConsentKeys API endpoints:
  - Authorization URL: `https://api.pseudoidc.consentkeys.com/auth`
  - Token URL: `https://api.pseudoidc.consentkeys.com/token`
  - UserInfo URL: `https://api.pseudoidc.consentkeys.com/userinfo`

#### API Configuration and Endpoints

ConsentKeys provides an OpenID Connect discovery endpoint that contains all the API endpoints and configuration your application needs:

**OpenID Configuration URL:**
```
https://api.pseudoidc.consentkeys.com/.well-known/openid-configuration
```

This endpoint returns a JSON document with:
- Authorization endpoint
- Token endpoint
- UserInfo endpoint
- Supported scopes
- Supported response types
- And other OAuth/OIDC configuration

**Reference:** For detailed API documentation, refer to the [ConsentKeys OAuth Application Setup Guide](https://doc.clickup.com/90132503056/d/h/2ky51pgg-2693/4fa372dec4eb9b6)

### Step 1: Clone and Enter the Repository

```bash
# Clone this repository
git clone <your-repo-url>
cd nix-flake

# Enter the Nix development environment
# This will automatically install all required tools
nix develop
```

**What happens:**
- Nix will download and install: Supabase CLI, Vercel CLI, GitHub CLI, Node.js 20, Yarn, Git, jq, and curl
- On first run, you'll be prompted to run interactive setup

### Step 2: Run Initial Setup

When you first enter `nix develop`, you'll be asked:

```
Run interactive setup for Supabase, Vercel, GitHub, and Frontend? (Y/n):
```

Type `Y` and press Enter to proceed with automated setup.

**The setup will guide you through:**

#### 2a. Supabase Setup (`setup-supabase`)

**⚠️ Prerequisite:** Make sure you've completed [Step 0: Create ConsentKeys OAuth Application](#step-0-create-consentkeys-oauth-application) first, as you'll need your Client ID and Client Secret during this setup.

1. **Authentication:**
   - If not logged in, you'll be prompted to authenticate
   - This opens your browser for Supabase login
   - After login, you'll return to the terminal

2. **Project Initialization:**
   - If no Supabase project exists locally, it will run `supabase init`
   - You'll be asked to:
     - **Option 1:** Link to existing cloud project
     - **Option 2:** Create new cloud project (opens browser)
     - **Option 3:** Skip for now

3. **Edge Function Setup:**
   - The ConsentKeys callback edge function is already in the repo
   - Location: `supabase/functions/consentkeys-callback/index.ts`
   - **JWT verification is already disabled** (see `supabase/functions/consentkeys-callback/config.toml`)

4. **Edge Function Secrets:**
   - You'll be prompted to configure secrets
   - Required secrets:
     - `CONSENT_KEYS_TOKEN_URL` (default: `https://api.pseudoidc.consentkeys.com/token`)
     - `CONSENT_KEYS_USERINFO_URL` (default: `https://api.pseudoidc.consentkeys.com/userinfo`)
     - `CONSENT_KEYS_CLIENT_ID` (your ConsentKeys client ID from Step 0)
     - `CONSENT_KEYS_CLIENT_SECRET` (your ConsentKeys client secret from Step 0)
     - `APP_URL` (default: `http://localhost:5173/auth/callback`)
   - **Note:** `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are automatically available and don't need to be set

5. **Deploy Edge Function:**
   - You'll be asked if you want to deploy the function now
   - If yes, it runs: `supabase functions deploy consentkeys-callback --no-verify-jwt`
   - The `--no-verify-jwt` flag ensures JWT verification is disabled (required for ConsentKeys OAuth flow)

**Manual alternative:** If setup fails, you can set secrets manually:
```bash
# Get your project reference ID first
supabase projects list

# Set secrets (replace PROJECT_REF with your actual project reference)
supabase secrets set CONSENT_KEYS_TOKEN_URL="https://api.pseudoidc.consentkeys.com/token" --project-ref PROJECT_REF
supabase secrets set CONSENT_KEYS_USERINFO_URL="https://api.pseudoidc.consentkeys.com/userinfo" --project-ref PROJECT_REF
supabase secrets set CONSENT_KEYS_CLIENT_ID="your_client_id" --project-ref PROJECT_REF
supabase secrets set CONSENT_KEYS_CLIENT_SECRET="your_client_secret" --project-ref PROJECT_REF
supabase secrets set APP_URL="http://localhost:5173/auth/callback" --project-ref PROJECT_REF
```

#### 2b. Vercel Setup (`setup-vercel`)

1. **Authentication:**
   - You'll be prompted to log in to Vercel
   - This opens your browser for authentication
   - After login, return to the terminal

2. **Project Linking:**
   - You'll be asked to link to an existing project or create a new one
   - Follow the prompts

#### 2c. GitHub Setup (`setup-github`)

1. **Authentication:**
   - You'll be prompted to authenticate with GitHub
   - This opens your browser for OAuth
   - After authentication, return to the terminal

2. **Repository Setup:**
   - You can link to an existing repository or create a new one
   - Follow the prompts

#### 2d. Frontend Setup (`setup-frontend`)

1. **Dependencies:**
   - Checks if `package.json` exists
   - Verifies dependencies are installed
   - If missing, runs `yarn install` or `npm install`

2. **Environment Variables:**
   - Checks if `.env` file exists
   - If not, helps you create it from `env.example`

### Step 3: Configure Environment Variables

After setup, create your `.env` file:

```bash
# Copy the example file
cp env.example .env
```

Then edit `.env` with your actual credentials:

```bash
# Supabase credentials (get from: https://supabase.com/dashboard → Your Project → Settings → API)
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY=your-anon-key-here

# ConsentKeys OAuth configuration
VITE_CONSENT_KEYS_AUTHORIZE_URL=https://api.pseudoidc.consentkeys.com/auth
VITE_CONSENT_KEYS_CLIENT_ID=ck_your_client_id_here
VITE_CONSENT_KEYS_REDIRECT_URI=https://your-project-id.supabase.co/functions/v1/consentkeys-callback
```

**Where to find Supabase credentials:**
1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to Settings → API
4. Copy the "Project URL" → `VITE_SUPABASE_URL`
5. Copy the "anon public" key → `VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY`

**Important:** 
- The `VITE_CONSENT_KEYS_REDIRECT_URI` must match your Supabase project URL + `/functions/v1/consentkeys-callback`
- After updating `.env`, restart your dev server

### Step 4: Verify Edge Function Configuration

The ConsentKeys edge function is pre-configured with JWT verification **disabled**. This is required because ConsentKeys uses OAuth flow, not JWT tokens.

**Verify the local configuration:**

```bash
# Check the config file
cat supabase/functions/consentkeys-callback/config.toml
```

You should see:
```toml
[functions.consentkeys-callback]
verify_jwt = false
```

**Important Notes:**
- The `config.toml` file may not appear in the Supabase Dashboard file list (only code files like `index.ts` are shown)
- However, the configuration is still applied when deploying with the `--no-verify-jwt` flag
- You can also verify/configure JWT settings in the Dashboard: Edge Functions → consentkeys-callback → Settings tab
- The Dashboard UI toggle should be set to **OFF** (which you've already done)

**This is correct!** The function handles its own authentication via the OAuth flow.

### Step 5: Start Development

```bash
# Start the development server
yarn dev
# or
npm run dev
```

The app will be available at `http://localhost:5173`

**Test the authentication flow:**
1. Navigate to the login page
2. Click "Login with ConsentKeys"
3. You'll be redirected to ConsentKeys for authentication
4. After authentication, you'll be redirected back to your app

## Environment Variables

### Frontend Environment Variables (`.env`)

These variables are used by your React/Vite frontend:

```bash
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY=your-anon-key

# ConsentKeys OAuth Configuration
VITE_CONSENT_KEYS_AUTHORIZE_URL=https://api.pseudoidc.consentkeys.com/auth
VITE_CONSENT_KEYS_CLIENT_ID=ck_your_client_id
VITE_CONSENT_KEYS_REDIRECT_URI=https://your-project-id.supabase.co/functions/v1/consentkeys-callback
```

**Note:** The `VITE_` prefix is required for Vite to expose these variables to the frontend.

### Edge Function Secrets

These are set in Supabase Dashboard or via CLI (not in `.env`):

- `CONSENT_KEYS_TOKEN_URL` - Token endpoint (default: `https://api.pseudoidc.consentkeys.com/token`)
- `CONSENT_KEYS_USERINFO_URL` - UserInfo endpoint (default: `https://api.pseudoidc.consentkeys.com/userinfo`)
- `CONSENT_KEYS_CLIENT_ID` - Your ConsentKeys OAuth client ID
- `CONSENT_KEYS_CLIENT_SECRET` - Your ConsentKeys OAuth client secret
- `APP_URL` - Frontend callback URL (default: `http://localhost:5173/auth/callback`)

**Automatically available (don't set manually):**
- `SUPABASE_URL` - Automatically provided by Supabase
- `SUPABASE_SERVICE_ROLE_KEY` - Automatically provided by Supabase

**To set secrets via Supabase Dashboard:**
1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to Settings → Edge Functions → Secrets
4. Add each secret key-value pair

## Edge Function Configuration

### JWT Verification (Already Disabled)

The ConsentKeys edge function has JWT verification **disabled by default**. This is configured in two ways:

1. **Local config file:** `supabase/functions/consentkeys-callback/config.toml`
   ```toml
   [functions.consentkeys-callback]
   verify_jwt = false
   ```

2. **Deployment flag:** Use `--no-verify-jwt` when deploying:
   ```bash
   supabase functions deploy consentkeys-callback --no-verify-jwt
   ```

3. **Dashboard UI:** Edge Functions → consentkeys-callback → Settings → "Verify JWT with legacy secret" should be **OFF**

**Important:** The `config.toml` file may not appear in the Supabase Dashboard file list (only code files like `index.ts` are shown), but the configuration is still applied when you:
- Deploy with the `--no-verify-jwt` flag, OR
- Set it manually in the Dashboard Settings tab

**Why is this necessary?**
- ConsentKeys uses OAuth 2.0 authorization code flow
- The callback function receives an authorization code, not a JWT token
- The function handles its own authentication by exchanging the code for tokens
- JWT verification would block the OAuth flow

**Do not enable JWT verification** for this function, as it will break the ConsentKeys authentication flow.

### Edge Function Flow

1. User clicks "Login with ConsentKeys" → Redirected to ConsentKeys
2. User authenticates → ConsentKeys redirects to edge function with `code` parameter
3. Edge function exchanges `code` for access token
4. Edge function fetches user info using access token
5. Edge function creates/finds user in Supabase
6. Edge function generates magic link
7. User is redirected to frontend with magic link
8. Frontend completes authentication

## Available Commands

After entering the environment with `nix develop`:

### Setup Commands

- `setup-all` - Re-run all setup scripts (Supabase, Vercel, GitHub, Frontend)
- `setup-supabase` - Configure Supabase only (authentication, project linking, edge function secrets)
- `setup-vercel` - Configure Vercel only (authentication, project linking)
- `setup-github` - Configure GitHub only (authentication, repository setup)
- `setup-frontend` - Verify frontend setup (dependencies, .env file)
- `verify-edge-function` - Verify edge function structure and configuration

### Development Commands

- `supabase-dev` or `supabase start` - Start local Supabase instance (requires Docker)
- `supabase-stop` or `supabase stop` - Stop local Supabase
- `supabase status` - Show local Supabase credentials and status
- `dev` or `yarn dev` - Start Vite development server (recommended for local development)
- `vercel dev` - Start Vercel development server (for testing Vercel-specific features)
- `deploy` or `vercel --prod` - Deploy to Vercel production

### Supabase Commands

- `supabase functions deploy consentkeys-callback --no-verify-jwt` - Deploy the edge function with JWT verification disabled
- `supabase functions list` - List all deployed functions
- `supabase secrets list` - List all edge function secrets
- `supabase secrets set KEY=value --project-ref PROJECT_REF` - Set a secret

**Note:** Always use `--no-verify-jwt` when deploying the ConsentKeys callback function, as it uses OAuth flow instead of JWT tokens.

## Troubleshooting

### Nix Command Not Found

**Problem:** `nix: command not found`

**Solution:**
1. Verify Nix is installed: `ls /nix` should show the Nix directory
2. Add to `~/.zshrc`:
   ```bash
   # Nix
   export PATH="/nix/var/nix/profiles/default/bin:$PATH"
   if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then 
     . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
   fi
   ```
3. Restart terminal or run `source ~/.zshrc`

### Edge Function Not Working

**Problem:** Edge function returns errors or doesn't authenticate

**Checklist:**
1. ✅ Verify JWT is disabled locally: `cat supabase/functions/consentkeys-callback/config.toml` should show `verify_jwt = false`
2. ✅ Verify JWT is disabled in Dashboard: Edge Functions → consentkeys-callback → Settings → "Verify JWT with legacy secret" should be **OFF**
3. ✅ When deploying, use: `supabase functions deploy consentkeys-callback --no-verify-jwt`
4. ✅ Check secrets are set: Go to Supabase Dashboard → Edge Functions → Secrets
5. ✅ Verify function is deployed: `supabase functions list`
6. ✅ Check redirect URI matches: Must be `https://your-project-id.supabase.co/functions/v1/consentkeys-callback`
7. ✅ Verify ConsentKeys client ID and secret are correct

**Note:** The `config.toml` file may not appear in the Dashboard file list, but the `--no-verify-jwt` flag ensures the setting is applied during deployment.

### Environment Variables Not Loading

**Problem:** Frontend can't access environment variables

**Solution:**
1. Ensure variables start with `VITE_` prefix
2. Restart dev server after changing `.env`
3. Check `.env` file is in project root (same directory as `package.json`)
4. Verify no typos in variable names

### Supabase Connection Issues

**Problem:** Can't connect to Supabase

**Checklist:**
1. ✅ Verify `VITE_SUPABASE_URL` is correct (no trailing slash)
2. ✅ Verify `VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY` is the "anon public" key (not service role key)
3. ✅ Check Supabase project is active in dashboard
4. ✅ Verify network connectivity

## 🔄 Reproducibility

This environment is **fully reproducible** across machines:

✅ **Reproducible:**
- All development tools (via Nix flake - same versions everywhere)
- Setup automation scripts
- Frontend code structure
- Environment variable templates
- Edge function code and configuration

⚠️ **User-specific (not committed):**
- `.env` file with your credentials (gitignored)
- Supabase/Vercel/GitHub project links (stored locally)
- Edge function secrets (stored in Supabase Dashboard)
- Local development preferences

**To reproduce on a new machine:**
1. Clone the repo
2. Run `nix develop` (same tools, same versions)
3. Run `setup-all` (same automation)
4. Create `.env` with your credentials
5. Set edge function secrets in Supabase Dashboard
6. Start developing!

## 📦 What's Included

- **Supabase CLI** - Local database & cloud project management
- **Vercel CLI** - Deployment and preview environments
- **GitHub CLI** - Repository and PR management
- **Node.js 20** - Modern JavaScript runtime
- **Yarn** - Package manager
- **Git, jq, curl** - Essential development tools

## ⚛️ Frontend

This repository **already includes** a complete React + Vite + TypeScript frontend with:
- ✅ Pre-configured Supabase integration
- ✅ ConsentKeys OAuth authentication flow
- ✅ Protected routes and auth context
- ✅ Environment variable configuration
- ✅ Ready-to-use project structure

## 🎯 Use Cases

Perfect for:
- Full-stack apps with Supabase backend
- Next.js/React projects deploying to Vercel
- Projects using AI coding assistants (VibeCode, Claude Code, Cursor)
- Team collaboration with reproducible environments
- OAuth authentication with ConsentKeys

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

## 🤝 Contributing

Feel free to submit issues and PRs!

## 📄 License

MIT
