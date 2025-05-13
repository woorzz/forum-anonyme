<template>
    <NavBar />
  <div class="min-h-screen bg-white py-10">
    <div class="max-w-4xl mx-auto px-4">
      <header class="mb-8 text-center">
        <h1 class="text-4xl font-extrabold text-gray-900">
          Forum Anonyme 
        </h1>
      </header>

      <section>
        <div v-if="pending" class="text-center text-gray-500">Chargement des messages...</div>
        <div v-else-if="error" class="text-center text-red-500">Échec de chargement des messages.</div>
        <ul v-else class="space-y-6">
          <li
            v-for="msg in messages"
            :key="msg.id"
            class="bg-white shadow-md rounded-lg p-6 hover:shadow-lg transition-shadow duration-200"
          >
            <div class="flex items-center justify-between mb-2">
              <span class="text-blue-600 font-semibold">@{{ msg.pseudo }}</span>
              <span class="text-sm text-gray-400">{{ formatDate(msg.created_at) }}</span>
            </div>
            <p class="text-gray-700 leading-relaxed">{{ msg.text }}</p>
          </li>
        </ul>
      </section>
    </div>
  </div>
</template>

<script setup>
import { useFetch } from '#app'
import NavBar from '~/components/NavBar.vue'
import { formatDate } from '~/utils/format';

const { data: messages, pending, error } = await useFetch('http://api:3000/messages')

</script>

