<template>
  <div style="height: 100vh; width: 100vw; overflow: hidden">
    <!-- <canvas id="self-render" class="content-area"></canvas> -->
    <!-- <div style="width: 50%; height: 50%; background-color: rgba(0,0,0,0.5)"></div> -->
    <!-- <canvas class="video-recorder-canvas" id="video-recorder-canvas"></canvas> -->

    <div v-if="show === true || halfShow === true" :style="getStyle()">
      <div class="phone_wrapper" :style="classObject()">
        <div
          v-if="currentCover"
          class="phone_coque"
          :style="{
            backgroundImage:
              'url(/html/static/img/cover/' + currentCover.value + ')',
          }"
        ></div>

        <div id="app" class="phone_screen noselect">
          <!-- <transition-page :isChanging="isChanging"/> :class="{ 'transition': isChanging }" :style="getStyle(brightness)" -->
          <!-- <video id="target-stream" class="content-area" style="display: none;" autoplay muted></video> -->
          <notification />
          <router-view />
          <!--
            assegnando i componenti inferiori a vari path posso mostrare più
            router assieme e farci l'animazione
            <router-view style="position: absolute;" name="default"/>
          -->
        </div>
      </div>
    </div>

    <!-- <div class="test-elem"></div> -->
    <!-- <video style="z-index: 0;" id="test-video-element" src="/html/static/img/Montage_Jojo.mp4" crossorigin="anonymous" autoplay controls loop></video> -->
  </div>
</template>

<script>
import "./PhoneBaseStyle.css";
import "./assets/css/cssgram.css";

import { mapGetters, mapActions } from "vuex";
import Notification from "@/components/Notification/Notification";

export default {
  name: "app",
  components: { Notification },
  data() {
    return {
      soundCall: null,
      isChanging: false,
      currentRoute: window.location.pathname,
      audioElement: new Audio(),
    };
  },
  methods: {
    ...mapActions(["rejectCall"]),
    closePhone() {
      this.$phoneAPI.closePhone();
    },
    getStyle() {
      return { zoom: this.zoom };
    },
    classObject() {
      if (this.brightnessActive) {
        if (this.halfShow && !this.show) {
          return {
            filter: "brightness(" + (this.brightness / 100 + 0.1) + ")",
            top: "70vh",
          };
        } else {
          return {
            filter: "brightness(" + (this.brightness / 100 + 0.1) + ")",
          };
        }
      }
      return {};
    },
  },
  computed: {
    ...mapGetters([
      "show",
      "halfShow",
      "zoom",
      "currentCover",
      "suoneria",
      "appelsInfo",
      "myPhoneNumber",
      "volume",
      "brightness",
      "brightnessActive",
    ]),
  },
  watch: {
    appelsInfo(newValue, oldValue) {
      if (this.appelsInfo !== null && this.appelsInfo.is_accepts !== true) {
        if (this.soundCall !== null) {
          this.soundCall.pause();
        }
        var path = null;
        if (this.appelsInfo.initiator === true) {
          path = "/html/static/sound/Phone_Call_Sound_Effect.ogg";
        } else {
          path = "/html/static/sound/" + this.suoneria.value;
        }
        this.audioElement.src = path;
        this.audioElement.loop = true;
        this.soundCall = this.audioElement;
        this.soundCall.volume = this.volume;
        this.soundCall.play();
      } else if (this.soundCall !== null) {
        this.soundCall.pause();
        this.soundCall = null;
      }
      if (newValue === null && oldValue !== null) {
        this.$router.push({ name: "lockscreen" });
        return;
      }
      if (newValue !== null) {
        this.$router.push({ name: "appels.active" });
      }
    },
    show() {
      if (this.appelsInfo !== null) {
        this.$router.push({ name: "appels.active" });
      } else {
        this.$router.push({ name: "lockscreen" });
      }
      if (this.show === false && this.appelsInfo !== null) {
        this.rejectCall();
      }
    },
  },
  mounted() {
    window.addEventListener("message", (event) => {
      if (event.data.keyUp !== undefined) {
        this.$bus.$emit("keyUp" + event.data.keyUp);
      }
    });
    if (process.env.NODE_ENV !== "production") {
      const keyValid = [
        "ArrowRight",
        "ArrowLeft",
        "ArrowUp",
        "ArrowDown",
        "Backspace",
        "Enter",
      ];
      window.addEventListener("keyup", (event) => {
        if (keyValid.includes(event.key) !== -1)
          this.$bus.$emit("keyUp" + event.key);
        if (event.key === "Escape") this.$phoneAPI.closePhone();
      });
    }
  },
  created() {
    this.$router.push({ name: "lockscreen" });
  },
};
</script>

<style scoped>
.noselect {
  user-select: none;
}

.blocked-screen {
  overflow: hidden;
  position: absolute;
  background-color: white;
  width: 330px;
  height: 742px;
  bottom: 100px;
  left: 48px;
  right: 50px;
  top: 100px;
  border-radius: 6px;

  background-color: grey;
}

.blocked-screen-flex {
  width: 100%;
  height: 100%;

  display: flex;
  flex-direction: column;
}

.blocked-screen-flex span {
  color: white;
  align-self: center;
  margin: auto;
  text-align: center;
}

#canvas-recorder {
  display: none;
  overflow: hidden;
  width: 100vw;
  height: 100vh;
}

/*
.test-elem {
  position: absolute;
  bottom: 550px;
  left: 500px;
  width: 50px;
  height: 50px;
  background-color: red;
  animation: test 1.0s linear infinite;
}

@keyframes test {
  50% {
    transform: rotate(180deg)
  }
}
*/
</style>
