// Deno type declarations for Supabase Edge Functions
// Deno is available at runtime, these are just for TypeScript checking

declare namespace Deno {
  export namespace env {
    export function get(key: string): string | undefined
  }
}

