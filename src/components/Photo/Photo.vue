<script>
import { mapActions } from 'vuex'

export default {
  methods: {
    ...mapActions(['addPhoto'])
  },

  async created () {
    const url = await this.$phoneAPI.takePhoto()
    this.addPhoto({ link: url })
    this.$router.push({ name: 'galleria.slpash' })
  }
}
</script>
