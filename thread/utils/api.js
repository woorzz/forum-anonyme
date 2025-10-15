import { useRuntimeConfig } from '#imports'

export function getApiBase() {
  const { public: { apiBaseDev, apiBaseProd } } = useRuntimeConfig()
  return import.meta.dev ? apiBaseDev : apiBaseProd
}

export function getApiUrl(endpoint = '') {
  return `${getApiBase()}${endpoint}`
}
