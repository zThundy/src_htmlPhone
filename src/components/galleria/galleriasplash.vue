<template>
  <div class="splash">
    <img src="/html/static/img/icons_app/galleria.png" alt="">
  </div>
</template>

<script>
export default {
  name: 'galleria_splash',
  created: function () {
    setTimeout(() => {
      this.$router.push({ name: 'galleria' })
    }, 700)
  }
}
</script>

<style scoped>
.splash {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;

  background: rgb(227,193,139);
  background: linear-gradient(350deg, rgba(227,193,139,1) 0%, rgba(207,99,88,1) 100%);
}

img {
  animation-name: zoom;
  animation-duration: 0.7s;
  animation-fill-mode: forwards;
}

@keyframes zoom {
  from {
    width: 20%;
  }
  to {
    width: 80%;
  }
}
</style>
