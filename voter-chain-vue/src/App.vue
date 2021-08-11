<template>
  <v-app>
    <v-slide-x-transition leave-absolute>
      <router-view />
    </v-slide-x-transition>
    <v-toast/>
    <v-confirmation/>
  </v-app>
</template>

<script lang="ts">
  import {Vue, Component} from "vue-property-decorator";
  import VToast from "./vuetify-extensions/VToast.vue";
  import VConfirmation from "./vuetify-extensions/VConfirmation.vue";

  @Component({
    components: {
      VToast,
      VConfirmation
    }
  })
  export default class App extends Vue {}
</script>