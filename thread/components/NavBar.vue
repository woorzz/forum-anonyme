<template>
  <nav class="bg-white shadow-md py-4 px-6">
    <div class="max-w-6xl mx-auto flex items-center justify-between">
      <h1 class="text-xl sm:text-2xl font-extrabold text-gray-800">
        Forum Anonyme
      </h1>

      <div class="flex space-x-6">
        <a
          :href="`${envConfig.threadUrl}/thread`"
          class="text-gray-700 font-medium hover:text-blue-600 transition"
        >
          Lire les messages
        </a>
        <a
          :href="`${envConfig.senderUrl}/sender`"
          class="text-gray-700 font-medium hover:text-blue-600 transition"
        >
          Envoyer un message
        </a>
      </div>
    </div>
  </nav>
</template>

<script setup>
const envConfig = {
  threadUrl: import.meta.env.VITE_THREAD_URL || '',
  senderUrl: import.meta.env.VITE_SENDER_URL || ''
}
</script>
