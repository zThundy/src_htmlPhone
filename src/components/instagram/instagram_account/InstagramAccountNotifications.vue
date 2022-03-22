<template>
  <div class="flex">
    <div class="middle">
      <i class="fa fa-bell insta-icon"></i>
    </div>

    <div class="bottom">
      <div class="container" :class="{ select: currentIndex === 0 }">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_ALL') }}</span>
        <CustomSwitch class="switch" :backgroundColor="'rgb(60, 60, 60)'" v-model="notificationValues[0]"/>
        <input type="button" data-action="toggleNotifications" style="display: none" />
      </div>

      <div class="container" :class="{ select: currentIndex === 1 }">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_MENTION') }}</span>
        <CustomSwitch class="switch" :backgroundColor="'rgb(60, 60, 60)'" v-model="notificationValues[1]"/>
        <input type="button" data-action="toggleNotifications" style="display: none" />
      </div>

      <div class="container" :class="{ select: currentIndex === 2 }">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_NEVER') }}</span>
        <CustomSwitch class="switch" :backgroundColor="'rgb(60, 60, 60)'" v-model="notificationValues[2]"/>
        <input type="button" data-action="toggleNotifications" style="display: none" />
      </div>

      <div class="container" :class="{ select: currentIndex === 3 }">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_SOUND') }}</span>
        <CustomSwitch class="switch" :backgroundColor="'rgb(60, 60, 60)'" v-model="instagramNotificationSound"/>
        <input type="button" data-action="toggleNotificationsSound" style="display: none" />
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex"
import CustomSwitch from '@/components/CustomSwitch'

export default {
  components: { CustomSwitch },
  data () {
    return {
      currentIndex: 0,
      notificationValues: [false, false, false]
    }
  },
  computed: {
    ...mapGetters([
      "LangString",
      'instagramNotification',
      'instagramNotificationSound',
    ])
  },
  methods: {
    ...mapActions([
      "setInstagramNotificationSound",
      "setInstagramNotification",
      "addTweet"
    ]),
    toggleNotificationsSound() {
      this.setInstagramNotificationSound(!this.instagramNotificationSound)
    },
    toggleNotifications() {
      this.notificationValues = [false, false, false]
      this.notificationValues[this.currentIndex] = !this.notificationValues[this.currentIndex]
      this.currentIndex--
      this.currentIndex++
      this.setInstagramNotification(this.notificationValues)
    },

    /* FUNZIONI CONTROLLI */
    onUp() {
      if (this.currentIndex === 0) return
      this.currentIndex--
    },
    onDown() {
      this.currentIndex++
    },
    onEnter() {
      const select = document.querySelector('.select')
      if (!select) return
      const input = select.querySelector('input')
      if (!input) return

      switch(input.type) {
        case "button":
          if (input.dataset.action)
            if (this[input.dataset.action])
              this[input.dataset.action](input.dataset.args || null)
          break
      }
    },
  },
  created() {
    this.notificationValues = this.instagramNotification
    this.$bus.$on("instagramOnUP", this.onUp)
    this.$bus.$on("instagramOnDown", this.onDown)
    this.$bus.$on("instagramOnEnter", this.onEnter)
  },
  beforeDestroy() {
    this.$bus.$off("instagramOnUP", this.onUp)
    this.$bus.$off("instagramOnDown", this.onDown)
    this.$bus.$off("instagramOnEnter", this.onEnter)
  }
}
</script>

<style>
@import url("./style.css");

.container.select {
  background-color: rgba(58, 58, 58, 0.2);
}

.container {
  width: 100%;
  height: 40px;
  position: relative;
  display: flex;
  flex-direction: row;
  margin-top: 2%;
  margin-bottom: 2%;
}

.container span {
  position: relative;
  margin-top: 2%;
  font-size: 20px;
  font-weight: bold;
  width: 80%;
  float: left;
  padding-left: 4%;
}

.container .switch {
  position: relative;
  margin-top: 2%;
  float: right;
}

.flex {
  display: flex;
  flex-direction: column;
}

.middle {
  text-align: center;
}

.bottom {
  margin-top: 30%;
}
</style>
