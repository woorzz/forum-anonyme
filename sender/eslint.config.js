import js from "@eslint/js";
import globals from "globals";
import pluginVue from "eslint-plugin-vue";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    ignores: [".nuxt/**", "node_modules/**"]
  },
  {
    files: ["**/*.{js,mjs,cjs,vue}"],
    plugins: { js },
    extends: ["js/recommended"],
  },
  {
    files: ["**/*.{js,mjs,cjs,vue}"],
    languageOptions: { globals: globals.browser },
  },
  pluginVue.configs["flat/essential"],
  {
    files: ["**/*.vue"],
    rules: {
      "vue/multi-word-component-names": "off",
    },
  },
  {
    files: ["test/**/*.test.{js,ts,vue}"],
    languageOptions: {
      globals: {
        describe: "readonly",
        it: "readonly",
        expect: "readonly",
        beforeEach: "readonly",
        afterEach: "readonly",
      }
    }
  }
]);