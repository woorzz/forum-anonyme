// Composable pour accéder à la configuration runtime (window.ENV_CONFIG)
// avec fallback sur la configuration Nuxt classique
import { useRuntimeConfig } from '#app'

export const useEnvConfig = () => {
  const config = useRuntimeConfig()
  
  // En mode client, on privilégie window.ENV_CONFIG si disponible
  if (process.client && typeof window !== 'undefined' && window.ENV_CONFIG) {
    return {
      apiBase: window.ENV_CONFIG.NUXT_PUBLIC_API_BASE || config.public.apiBase,
      senderUrl: window.ENV_CONFIG.NUXT_PUBLIC_SENDER_URL || config.public.senderUrl,
      threadUrl: window.ENV_CONFIG.NUXT_PUBLIC_THREAD_URL || config.public.threadUrl
    }
  }
  
  // Fallback sur la configuration Nuxt (SSR ou si window.ENV_CONFIG absent)
  return {
    apiBase: config.public.apiBase,
    senderUrl: config.public.senderUrl,
    threadUrl: config.public.threadUrl
  }
}
