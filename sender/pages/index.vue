<template>
  <main class="flex-1 flex flex-col items-center justify-center bg-gray-50 px-4">
    <div class="flex flex-col space-y-6 w-full max-w-xs">
      <a
        :href="threadUrl"
        class="w-full px-6 py-4 bg-white text-blue-600 font-bold text-center rounded-2xl shadow-md hover:shadow-lg hover:bg-blue-50 transition duration-300 border border-blue-600"
      >
        Lire les messages
      </a>
      <a
        href="/sender"
        class="w-full px-6 py-4 bg-blue-600 text-white font-bold text-center rounded-2xl shadow-md hover:bg-blue-700 transition duration-300"
      >
        Poster un message
      </a>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'

// URL du thread (externe)
const threadUrl = ref('http://localhost/thread')

onMounted(() => {
  if (typeof window !== 'undefined' && window.RUNTIME_CONFIG) {
    threadUrl.value = `${window.RUNTIME_CONFIG.THREAD_URL}/thread`
  }
})
</script>
