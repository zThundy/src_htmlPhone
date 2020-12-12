<template>
  <div style="width: 334px; height: 678px; background: white" class="splash">
    <img src="/html/static/img/app_bank/bank.png" alt="">
  </div>
</template>

<script>
export default {
  created: function () {
    setTimeout(() => {
      this.$router.push({ name: 'bank' })
    }, 700)
  }
}
</script>

<style scoped>
.splash{
  width: 100%;
  height: 100%;
  background-color: #686868;
  display: flex;
  justify-content: center;
  align-items: center;
}

img {
  width: 80px;
  animation-name: zoom;
  animation-duration: 0.7s;
  animation-fill-mode: forwards;
}

@keyframes zoom {
  from {width: 80px;}
    to {width: 250px;}
}
</style>
