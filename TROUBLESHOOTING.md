# Troubleshooting Guide

## Dev Server Issues

### Issue: Vercel dev port timeout or crashes

**Symptoms:**
- `vercel dev` times out on port detection
- Dev server crashes after running for a while
- Port conflicts or errors

**Solutions:**

#### Option 1: Use Vite dev server directly (Recommended)
```bash
# Instead of: vercel dev
# Use:
yarn dev
# or
dev  # (alias in nix develop)
```

**Why:** Vite dev server is faster and more stable for local development. `vercel dev` is mainly useful for testing Vercel-specific features.

#### Option 2: Fix Vercel dev port issues
```bash
# Kill any process using the port
lsof -ti:60762 | xargs kill -9

# Or specify a different port
vercel dev --listen 3000
```

#### Option 3: Check for port conflicts
```bash
# Check what's using common ports
lsof -i :5173  # Vite default
lsof -i :3000  # Common dev port
lsof -i :60762 # Vercel detected port
```

### Issue: Dev server crashes

**Common causes:**
1. **Memory issues** - Node process running out of memory
2. **Port conflicts** - Another service using the same port
3. **File watcher limits** - Too many files being watched (macOS/Linux)

**Solutions:**

1. **Increase Node memory** (if needed):
   ```bash
   NODE_OPTIONS="--max-old-space-size=4096" yarn dev
   ```

2. **Check for port conflicts:**
   ```bash
   # Find what's using port 5173
   lsof -i :5173
   # Kill it if needed
   kill -9 <PID>
   ```

3. **Increase file watcher limits** (macOS):
   ```bash
   # Check current limit
   sysctl fs.inotify.max_user_watches  # Linux
   launchctl limit maxfiles  # macOS
   
   # Increase if needed (macOS)
   sudo launchctl limit maxfiles 65536 200000
   ```

4. **Use Vite dev instead of Vercel dev:**
   ```bash
   yarn dev  # More stable for local development
   ```

## Environment Variables

### Issue: Missing environment variables

See the error component in the browser for specific missing variables.

**Quick fix:**
```bash
# Copy example
cp env.example .env

# Edit with your values
# Then restart dev server
```

## Port Conflicts

### Check what's using a port:
```bash
lsof -i :PORT_NUMBER
# Example:
lsof -i :5173
```

### Kill process on a port:
```bash
lsof -ti:PORT_NUMBER | xargs kill -9
# Example:
lsof -ti:5173 | xargs kill -9
```

## Vercel Dev vs Vite Dev

**When to use `yarn dev` (Vite):**
- ✅ Local development (recommended)
- ✅ Faster startup
- ✅ More stable
- ✅ Better hot reload

**When to use `vercel dev`:**
- ✅ Testing Vercel Edge Functions locally
- ✅ Testing Vercel-specific features
- ✅ Simulating production environment

**Recommendation:** Use `yarn dev` for daily development, `vercel dev` only when needed.

## Common Commands

```bash
# Start Vite dev server (recommended)
yarn dev
# or
dev  # alias in nix develop

# Start Vercel dev (for Vercel features)
vercel dev

# Check for port conflicts
lsof -i :5173

# Kill process on port
lsof -ti:5173 | xargs kill -9

# Restart dev server
# Press Ctrl+C, then run again
```

## Still Having Issues?

1. **Check logs:**
   - Browser console for frontend errors
   - Terminal for server errors

2. **Restart everything:**
   ```bash
   # Kill all node processes
   pkill -f node
   
   # Restart dev server
   yarn dev
   ```

3. **Clear caches:**
   ```bash
   rm -rf node_modules/.vite
   yarn dev
   ```

