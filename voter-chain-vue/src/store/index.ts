import Vue from 'vue';
import Vuex from "vuex";
import AdminModule from "./AdminModule";

Vue.use(Vuex);

export default new Vuex.Store({
    modules: {
        AdminModule
    }
});