<template>
  <div class="min-h-screen flex flex-col bg-gray-50">
    <NavBar />
    <div class="flex-1 flex flex-col">
      <NuxtPage />
    </div>
    <Footer />
  </div>
</template>

<script setup>
import NavBar from '~/components/NavBar.vue'
import Footer from '~/components/Footer.vue'
</script>
