<template>
  <nav class="bg-white shadow-md py-4 px-6">
    <div class="max-w-6xl mx-auto flex items-center justify-between">
      <h1 class="text-xl sm:text-2xl font-extrabold text-gray-800">
        Forum Anonyme
      </h1>

      <div class="flex space-x-6">
        <a
          :href="threadUrl"
          class="text-gray-700 font-medium hover:text-blue-600 transition"
        >
          Lire les messages
        </a>
        <a
          :href="senderUrl"
          class="text-gray-700 font-medium hover:text-blue-600 transition"
        >
          Envoyer un message
        </a>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const threadUrl = ref('http://localhost/thread')
const senderUrl = ref('http://localhost:8080/sender')

onMounted(() => {
  if (typeof window !== 'undefined' && window.RUNTIME_CONFIG) {
    threadUrl.value = `${window.RUNTIME_CONFIG.THREAD_URL}/thread`
    senderUrl.value = `${window.RUNTIME_CONFIG.SENDER_URL}/sender`
  }
})
</script>
