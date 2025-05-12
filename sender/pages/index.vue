<template>
  <NavBar />
  <div class="min-h-screen bg-white py-10">

    <div class="max-w-2xl mx-auto px-4">
      <header class="mb-8 text-center">
        <h1 class="text-3xl font-extrabold text-gray-900">
          Envoyer un Message Anonyme
        </h1>
        <p class="mt-2 text-gray-600">
          Utilise un pseudonyme et partage ce que tu veux !
        </p>
      </header>

      <form @submit.prevent="sendMessage" class="space-y-6">
        <div>
          <label class="block mb-1 text-gray-700" for="pseudo">Pseudo</label>
          <input id="pseudo" v-model="pseudo" type="text" placeholder="Ton pseudo" required
            class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>

        <div>
          <label class="block mb-1 text-gray-700" for="content">Message</label>
          <textarea id="content" v-model="content" rows="5" placeholder="Ton message..." required
            class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"></textarea>
        </div>

        <button type="submit"
          class="w-full bg-blue-600 text-white font-semibold rounded-lg px-4 py-2 hover:bg-blue-700 transition-colors duration-200">
          Envoyer
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'
import NavBar from '../components/NavBar.vue'
const pseudo = ref('')
const content = ref('')

const sendMessage = async () => {
  if (!pseudo.value.trim() || !content.value.trim()) {
    alert('Merci de remplir pseudo et message !')
    return
  }
  try {
    await axios.post('http://localhost:3000/messages', {
      pseudo: pseudo.value,
      text: content.value,
    })
    alert('Message envoyé !')
    pseudo.value = ''
    content.value = ''
  } catch (err) {
    console.error('Erreur lors de l\'envoi', err)
    alert('Échec de l\'envoi du message.')
  }
}
</script>

