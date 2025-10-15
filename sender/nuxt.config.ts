// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  
  runtimeConfig: {
    public: {
      apiUrl: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:3000',
      threadUrl: process.env.NUXT_PUBLIC_THREAD_URL || 'http://localhost',
      senderUrl: process.env.NUXT_PUBLIC_SENDER_URL || 'http://localhost:8080'
    }
  },
  
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [
      tailwindcss(),
    ]
  }
});