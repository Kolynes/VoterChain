import Vue from 'vue';
import Router from 'vue-router';

import Dashboard from '@/views/dashboard/Dashboard';
import Home from '@/views/home/Home.vue';

Vue.use(Router);

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {path: "/", component: Home, props: route => route.query},
    {path: "/dashboard", component: Dashboard, props: route => route.query},
  ],
});
