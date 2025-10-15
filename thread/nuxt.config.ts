// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiBase: process.env.API_URL || 'http://localhost:3000', 
      apiUrl: process.env.API_URL || 'http://63.178.42.124:3000',
      apiBaseDev: 'http://localhost:3000',
      apiBaseProd: process.env.NUXT_PUBLIC_API_BASE_PROD || 'http://api:3000'
    }
  },
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [
      tailwindcss(),
    ],
    define: {
      __API_URL__: JSON.stringify(process.env.API_URL || 'http://localhost:3000')
    }
  },
});