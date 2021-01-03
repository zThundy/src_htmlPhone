<script>
// import { mapActions } from 'vuex'

export default {
  methods: {
    // ...mapActions(['addPhoto'])
  },

  async created () {
    const resp = await this.$phoneAPI.takePhoto()
    // this.addPhoto({ link: resp.url })
    if (resp) {
      this.$router.push({ name: 'galleria.splash', params: resp })
    }
  }
}
</script>
