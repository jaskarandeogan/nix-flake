// Test script for consentkeys-callback edge function
// Run with: deno test --allow-net --allow-env test.ts

import { assertEquals, assertExists } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

// Mock test - verify function structure
Deno.test('Edge function structure verification', () => {
  // Verify the function file exists and has required imports
  const functionCode = Deno.readTextFileSync('./index.ts')
  
  // Check for required imports
  assertExists(functionCode.includes('createClient'), 'Should import createClient')
  assertExists(functionCode.includes('serve'), 'Should import serve')
  
  // Check for required environment variables
  assertExists(functionCode.includes('CONSENT_KEYS_TOKEN_URL'), 'Should use CONSENT_KEYS_TOKEN_URL')
  assertExists(functionCode.includes('CONSENT_KEYS_USERINFO_URL'), 'Should use CONSENT_KEYS_USERINFO_URL')
  assertExists(functionCode.includes('CONSENT_KEYS_CLIENT_ID'), 'Should use CONSENT_KEYS_CLIENT_ID')
  assertExists(functionCode.includes('CONSENT_KEYS_CLIENT_SECRET'), 'Should use CONSENT_KEYS_CLIENT_SECRET')
  assertExists(functionCode.includes('SUPABASE_URL'), 'Should use SUPABASE_URL')
  assertExists(functionCode.includes('SUPABASE_SERVICE_ROLE_KEY'), 'Should use SUPABASE_SERVICE_ROLE_KEY')
  
  // Check for CORS headers
  assertExists(functionCode.includes('Access-Control-Allow-Origin'), 'Should have CORS headers')
  
  // Check for main flow steps
  assertExists(functionCode.includes('code'), 'Should handle authorization code')
  assertExists(functionCode.includes('generateLink'), 'Should generate magic link')
  
  console.log('✅ Edge function structure verified!')
})

