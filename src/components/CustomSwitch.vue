<template>
  <div
    class="custom-switch"
    :style="{ backgroundColor: backgroundColor }"
    :class="[ value ? 'active' : '' ]"
    @click="$_onChange($event)"
  ></div>
</template>

<script>
export default {
  name: 'custom-switch',
  props: {
    value: {
      type: Boolean,
      default: false
    },
    backgroundColor: {
      type: String,
      default: 'rgb(48, 134, 246)'
    }
  },
  data () {
    return { }
  },
  methods: {
    $_onChange (event) {
      this.$emit('input', !this.value)
      this.$emit('change', event)
    }
  }
}
</script>

<style lang="css">
.custom-switch {
  box-sizing: border-box;
  position: relative;
  width: 50px;
  height: 28px;
  border-radius: 48px;
  /* background-color: green; */
}

/* TRANSIZIONE EFFETTIVA */
.custom-switch::before, .custom-switch::after {
  content: "";
  position: absolute;
  transition: transform .4s;
}

/* SFONDO SWITCH OFF */
.custom-switch::before {
  top: 0;
  left: 0;
  width: 50px;
  height: 28px;
  border-radius: 23px;
  background-color: rgb(230, 230, 230);
}

/* PALLINO DENTRO */
.custom-switch::after {
  top: 4px;
  left: 4px;
  width: 20px;
  height: 20px;
  background-color: rgb(255, 255, 255);
  border-radius: 50%;
}

.custom-switch.active {
  /* background-color: green; */
  color: rgba(0,0,0,0);
}

.custom-switch.active::before {
  transform: scale(0);
}

.custom-switch.active::after {
  transform: translateX(22px);
}
</style>
