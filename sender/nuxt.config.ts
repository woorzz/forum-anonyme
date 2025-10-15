import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  runtimeConfig: {
    public: {
      apiBase: process.env.API_URL || 'http://localhost:3000'
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