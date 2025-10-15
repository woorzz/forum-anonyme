// Configuration API pour l'application Thread
export const API_CONFIG = {
  // En production, utiliser l'URL AWS, en dev utiliser localhost
  baseURL: process.env.NODE_ENV === 'production' 
    ? process.env.API_URL || 'http://api:3000'
    : 'http://localhost:3000'
}

// Fonction pour obtenir l'URL complète d'un endpoint
export function getApiUrl(endpoint = '') {
  return `${API_CONFIG.baseURL}${endpoint}`
}