// Original: https://github.com/egoist/vue-timeago
/* eslint-disable */
const MINUTE = 60
const HOUR = MINUTE * 60
const DAY = HOUR * 24
const WEEK = DAY * 7
const MONTH = DAY * 30
const YEAR = DAY * 365

function pluralOrSingular(data, locale) {
  if (data === 'just now') {
    return locale
  }
  const count = Math.round(data)
  if (Array.isArray(locale)) {
    return count > 1
      ? locale[1].replace(/%s/, count)
      : locale[0].replace(/%s/, count)
  }
  return locale.replace(/%s/, count)
}

function formatTime(time) {
  const d = new Date(time)
  return d.toLocaleString()
}

const defaultLocales = {
  'it_IT': [
    "Proprio adesso",
    ["%s secondo fa", "%s secondi fa"],
    ["%s minuto fa", "%s minuti fa"],
    ["%s ora fa", "%s ore fa"],
    ["%s giorno fa", "%s giorni fa"],
    ["%s settimana fa", "%s settimane fa"],
    ["%s mese fa", "%s mesi fa"],
    ["%s anno fa", "%s anni fa"]
  ]
}
export default function install(Vue, { name = 'timeago', locale = 'it_IT', locales = defaultLocales} = {} ) {

  if (!locales || Object.keys(locales).length === 0) {
    throw new TypeError('Expected locales to have at least one locale.')
  }
  const VueTimeago = {
    props: {
      since: {
        required: true
      },
      locale: String,
      maxTime: Number,
      autoUpdate: Number,
      format: Function
    },
    data() {
      return {
        now: new Date().getTime()
      }
    },
    computed: {
      currentLocale() {
        if (Vue.prototype.$timeago) {
          const locale = VueTimeago.locales[VueTimeago.locale]
          if (locale) {
            return locale
          }
        }
        return locales['it_IT']
      },
      sinceTime() {
        return new Date(this.since).getTime()
      },
      timeForTitle() {
        const seconds = this.now / 1000 - this.sinceTime / 1000

        if (this.maxTime && seconds > this.maxTime) {
          return null
        }

        return this.format
          ? this.format(this.sinceTime)
          : formatTime(this.sinceTime)
      },
      timeago() {
        const seconds = this.now / 1000 - this.sinceTime / 1000

        if (this.maxTime && seconds > this.maxTime) {
          clearInterval(this.interval)
          return this.format
            ? this.format(this.sinceTime)
            : formatTime(this.sinceTime)
        }

        const ret =
          seconds <= 5
            ? pluralOrSingular('just now', this.currentLocale[0])
            : seconds < MINUTE
              ? pluralOrSingular(seconds, this.currentLocale[1])
              : seconds < HOUR
                ? pluralOrSingular(seconds / MINUTE, this.currentLocale[2])
                : seconds < DAY
                  ? pluralOrSingular(seconds / HOUR, this.currentLocale[3])
                  : seconds < WEEK
                    ? pluralOrSingular(seconds / DAY, this.currentLocale[4])
                    : seconds < MONTH
                      ? pluralOrSingular(seconds / WEEK, this.currentLocale[5])
                      : seconds < YEAR
                        ? pluralOrSingular(
                            seconds / MONTH,
                            this.currentLocale[6]
                          )
                        : pluralOrSingular(
                            seconds / YEAR,
                            this.currentLocale[7]
                          )

        return ret
      }
    },
    mounted() {
      if (this.autoUpdate) {
        this.update()
      }
    },
    render(h) {
      return h(
        'time',
        {
          attrs: {
            datetime: new Date(this.since),
            title: this.timeForTitle
          }
        },
        this.timeago
      )
    },
    watch: {
      autoUpdate(newAutoUpdate) {
        this.stopUpdate()
        // only update when it's not falsy value
        // which means you cans set it to 0 to disable auto-update
        if (newAutoUpdate) {
          this.update()
        }
      }
    },
    methods: {
      update() {
        const period = this.autoUpdate * 1000
        this.interval = setInterval(() => {
          this.now = new Date().getTime()
        }, period)
      },
      stopUpdate() {
        clearInterval(this.interval)
        this.interval = null
      }
    },
    beforeDestroy() {
      this.stopUpdate()
    }
  }

  VueTimeago.locale = 'it_IT'
  VueTimeago.locales = {}
  
  Vue.prototype.$timeago = {
    setCurrentLocale (locale) {
      VueTimeago.locale = locale
    },
    addLocale (locale, data) {
      VueTimeago.locales[locale] = data
    }
  }

  Vue.component(name, VueTimeago)
}