<template>
  <div class="flex-1 flex items-center justify-center px-4 py-10">
    <div class="w-full max-w-md bg-white p-8 rounded-2xl shadow-md space-y-6">
      <h2 class="text-3xl font-bold text-gray-800 text-center">
        Envoyer un message anonyme
      </h2>

      <form @submit.prevent="sendMessage" class="space-y-6">
        <div>
          <label class="block text-gray-700 font-medium mb-2" for="pseudo">Pseudo</label>
          <input
            id="pseudo"
            v-model="pseudo"
            type="text"
            placeholder="Ton pseudo"
            required
            class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
          />
        </div>

        <div>
          <label class="block text-gray-700 font-medium mb-2" for="content">Message</label>
          <textarea
            id="content"
            v-model="content"
            rows="5"
            placeholder="Ton message..."
            required
            class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition resize-none"
          ></textarea>
        </div>

        <button
          type="submit"
          class="w-full py-3 bg-blue-600 text-white font-semibold rounded-xl shadow hover:bg-blue-700 transition duration-300"
        >
          Envoyer
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const pseudo = ref('')
const content = ref('')

const sendMessage = async () => {
  if (!pseudo.value.trim() || !content.value.trim()) {
    alert('Merci de remplir pseudo et message !')
    return
  }
  try {
    // Utiliser window.RUNTIME_CONFIG comme pour les autres pages
    const API_BASE = (typeof window !== 'undefined' && window.RUNTIME_CONFIG) 
      ? window.RUNTIME_CONFIG.API_URL 
      : 'http://localhost:3000'
      
    console.log('API_BASE utilisé:', API_BASE)
    await axios.post(`${API_BASE}/messages`, {
      pseudo: pseudo.value,
      text: content.value,
    })
    alert('Message envoyé !')
    pseudo.value = ''
    content.value = ''
  } catch (err) {
    console.error("Erreur lors de l'envoi", err)
    alert("Échec de l'envoi du message.")
  }
}
</script>
