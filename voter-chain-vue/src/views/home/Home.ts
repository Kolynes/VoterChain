import { Component, Vue } from "vue-property-decorator";

@Component
export default class Home extends Vue {

  connectToContract() {
    this.$router.push("/dashboard")
  }
}