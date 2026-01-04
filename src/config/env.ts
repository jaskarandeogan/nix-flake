const {
  VITE_CONSENT_KEYS_AUTHORIZE_URL: consentAuthorizeUrl,
  VITE_CONSENT_KEYS_CLIENT_ID: consentClientId,
  VITE_CONSENT_KEYS_REDIRECT_URI: consentRedirectUri,
} = import.meta.env

export const consentKeysEnv = {
  authorizeUrl: consentAuthorizeUrl,
  clientId: consentClientId,
  redirectUri: consentRedirectUri,
}

