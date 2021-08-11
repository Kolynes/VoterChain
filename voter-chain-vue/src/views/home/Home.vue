<template>
  <v-app>
    <v-app-bar app large>
      <v-avatar>
        <img src="../../assets/images/logo.svg">
      </v-avatar>
      <h1 class="title ml-2 font-weight-light">VoterChain</h1>
    </v-app-bar>
    <v-main>
      <v-container fill-height>
        <v-layout wrap align-center>
          <v-flex xs12 sm6 md8>
            <h1 class="display-3">VoterChain Administration</h1>
            <p class="body-1 my-3">Please make sure you are connected to MetaMask before you click the button below</p>
            <v-btn class="text-capitalize" large tile color="primary" @click="connectToContract">Continue <v-icon class="ml-3">mdi-arrow-right</v-icon></v-btn>
          </v-flex>
          <v-flex xs12 sm6 md4>
            <img style="width: 100%" src="../../assets/images/logo.svg">
          </v-flex>
        </v-layout>
      </v-container>
    </v-main>
  </v-app>
</template>

<script src="./Home.ts"></script>

<style>

</style>