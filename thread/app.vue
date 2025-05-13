<template>
  <div class="flex flex-col min-h-screen bg-gray-50">
    <NavBar />
    <NuxtPage />
    <Footer />

  </div>
</template>

<script setup>
import NavBar from '~/components/NavBar.vue'
import Footer from '~/components/Footer.vue'
</script>
