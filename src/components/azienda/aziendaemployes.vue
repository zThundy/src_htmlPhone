<template>
  <div style="width: 100%; height: 630px;">

    <div class="employes-container">
      <div class="employe-container" v-for="(elem, key) in myAziendaInfo.employes" :key="key" :class="{ selected: key === currentSelected }">
        <div class="employe-header">
          <div class="employe-status" :class="[ elem.isOnline ? 'online' : 'offline']">
            <div class="fa fa-user-o" aria-hidden="true"></div>
          </div>
          
          <div class="employe-title">
            <span>{{ elem.name }} ({{elem.phoneNumber}})</span>
          </div>
        </div>

        <div class="employe-divider"></div>

        <div class="employe-body">
          <div class="employe-grade-body">
            <span class="employe-grade-label">{{ LangString("APP_AZIENDA_GRADE_LABEL") }}:</span>
            <span class="employe-grade-text">{{elem.gradeName}} | {{elem.grade}}</span>
          </div>

          <div class="employe-salary-body">
            <span class="employe-salary-label">{{ LangString("APP_AZIENDA_SALARY_LABEL") }}:</span>
            <span class="employe-salary-text">{{elem.salary}} $</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'azienda-chat',
  components: {},
  data () {
    return {
      currentSelected: -1
    }
  },
  computed: {
    ...mapGetters(['LangString', 'aziendaIngoreControls', 'myAziendaInfo'])
  },
  watch: {
  },
  methods: {
    ...mapMutations(['SET_AZIENDA_IGNORE_CONTROLS']),
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.selected')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onUp () {
      if (this.aziendaIngoreControls) return
      if (this.currentSelected === -1) return
      this.currentSelected = this.currentSelected - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.aziendaIngoreControls) return
      if (this.currentSelected === this.myAziendaInfo.employes.length - 1) return
      this.currentSelected = this.currentSelected + 1
      this.scrollIntoView()
    },
    onEnter () {
      if (this.aziendaIngoreControls) return
      if (this.currentSelected === -1) return
      this.SET_AZIENDA_IGNORE_CONTROLS(true)
      try {
        let currentEmploye = this.myAziendaInfo.employes[this.currentSelected]
        let choix = [
          {id: 1, title: this.LangString('APP_AZIENDA_PROMOTE_EMPLOYE'), icons: 'fa-plus-square', color: 'green'},
          {id: 2, title: this.LangString('APP_AZIENDA_DEMOTE_EMPLOYE'), icons: 'fa-minus-square', color: 'orange'},
          {id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
        ]
        Modal.CreateModal({ choix }).then(resp => {
          if (resp.id === 1) {
            this.$phoneAPI.aziendaEmployesAction({ action: 'promote', employe: currentEmploye })
            this.SET_AZIENDA_IGNORE_CONTROLS(false)
          } else if (resp.id === 2) {
            this.$phoneAPI.aziendaEmployesAction({ action: 'demote', employe: currentEmploye })
            this.SET_AZIENDA_IGNORE_CONTROLS(false)
          } else if (resp.id === -1) { this.SET_AZIENDA_IGNORE_CONTROLS(false) }
        })
      } catch (e) { }
    },
    onBack () {
      if (this.aziendaIngoreControls) {
        this.SET_AZIENDA_IGNORE_CONTROLS(false)
      }
    }
  },
  created () {
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.employes-container {
  height: 94%;
  margin-top: 10px;
  overflow: hidden;
  border-radius: 20px;
}

.employe-container {
  width: 96%;
  height: 100px;
  background-color: rgb(255, 196, 123);

  margin-top: 10px;
  margin-left: auto;
  margin-right: auto;
  border-radius: 10px;
}

.employe-container.selected {
  background-color: rgb(255, 174, 75);
}

/* HEADER FOR SINGLE DIV */

.employe-header {
  width: 100%;
  height: 30px;

  display: flex;
  flex-direction: row;
}

/* ONLINE OFFLINE STATUS INDICATOR */

.employe-status {
  width: 24px;
  height: 24px;
  border-radius: 20px;

  margin-top: 5px;
  margin-left: 5px;
  font-size: 12px;
  text-align: center;
}

.employe-status div {
  height: 100%;
  width: 100%;
  margin-top: 5px;
}

.employe-status.online {
  background-color: rgb(50, 255, 50);
}

.employe-status.offline {
  background-color: rgb(255, 50, 50);
}

/* NAME AND NUMBER TITLE */

.employe-title {
  margin-top: 2px;
  margin-left: 8px;
}

.employe-title span {
  color: rgb(66, 66, 66);
  font-size: 15px;
  font-weight: bold;
}

/* END OF HEADER */

.employe-divider {
  width: 80%;
  height: 1px;
  background-color: rgb(66, 66, 66);
  border-radius: 2px;

  margin-left: auto;
  margin-right: auto;
}

/* START OF EMPLOYE BODY */

.employe-body {
  width: 100%;
  height: 70px;
}

/* EMPLOYE GRADE BODY */

.employe-grade-body {
  width: 100%;
  display: flex;
  flex-direction: row;
}

.employe-grade-body .employe-grade-label {
  color: rgb(150, 80, 0);
  font-weight: bold;
  font-size: 14px;

  margin-left: 10px;
  margin-top: 5px;
}

.employe-grade-body .employe-grade-text {
  color: rgb(0, 0, 0);
  font-weight: lighter;
  font-size: 14px;

  margin-left: 4px;
  margin-top: 5px;
}

/* EMPLOYE SALARY BODY */

.employe-salary-body {
  width: 100%;
  display: flex;
  flex-direction: row;
}

.employe-salary-body .employe-salary-label {
  color: rgb(150, 80, 0);
  font-weight: bold;
  font-size: 14px;

  margin-left: 10px;
  margin-top: 5px;
}

.employe-salary-body .employe-salary-text {
  color: rgb(0, 0, 0);
  font-weight: lighter;
  font-size: 14px;

  margin-left: 4px;
  margin-top: 5px;
}

</style>
