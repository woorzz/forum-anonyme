<template>
  <main class="flex-1 flex items-center justify-center px-4">
    <div class="w-full max-w-4xl space-y-10">
      <header class="text-center">
        <h1 class="text-4xl font-extrabold text-gray-800">
          Forum Anonyme
        </h1>
      </header>

      <section>
        <div v-if="pending" class="text-center text-gray-500">
          Chargement des messages...
        </div>
        <div v-else-if="error" class="text-center text-red-500">
          Erreur de chargement
        </div>
        <ul v-else class="space-y-6">
          <li
            v-for="msg in messages"
            :key="msg.id"
            class="bg-white p-6 rounded-2xl shadow-md hover:shadow-lg transition duration-300"
          >
            <div class="flex items-center justify-between mb-3">
              <span class="text-blue-600 font-semibold">@{{ msg.pseudo }}</span>
              <span class="text-sm text-gray-400">{{ formatDate(msg.created_at) }}</span>
            </div>
            <p class="text-gray-700 leading-relaxed whitespace-pre-line break-words">
              {{ msg.text }}
            </p>
          </li>
        </ul>
      </section>
    </div>
  </main>
</template>


<script setup>
import axios from 'axios'
import { ref, onMounted } from 'vue'
import { useRuntimeConfig } from '#app'

// Utiliser uniquement la configuration runtime de Nuxt
const config = useRuntimeConfig()
const API_BASE = config.public.apiBase

const messages = ref([])
const pending = ref(true)
const error = ref(null)

onMounted(async () => {
  try {
    console.log('API_BASE utilisé:', API_BASE)
    const response = await axios.get(`${API_BASE}/messages`)
    messages.value = response.data
  } catch (err) {
    error.value = err
    console.error('Erreur lors du chargement des messages:', err)
  } finally {
    pending.value = false
  }
})

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleString('fr-FR', {
    dateStyle: 'short',
    timeStyle: 'short'
  })
}
</script>
