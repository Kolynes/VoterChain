import Vue from 'vue';
import App from './App.vue';
import router from './router/index';
import store from './store';
import vuetify from './plugins/vuetify';
import Provider from './plugins/provider';
import "@/assets/css/material.css"

Provider.getDefaultProvider(() => {
  Vue.config.productionTip = false;

  store.commit("AdminModule/setTrackerContractAddress", {
    trackerContractAddress: localStorage.getItem("trackerContractAddress") || ""
  })
  new Vue({
    router,
    store,
    vuetify,
    render: (h) => h(App)
  }).$mount('#app');
});

