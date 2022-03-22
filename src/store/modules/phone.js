import Vue from 'vue'
import PhoneAPI from './../../PhoneAPI'

const state = {
  show: process.env.NODE_ENV !== 'production',
  halfShow: false,
  // show: false,
  myPhoneNumber: '555#####',
  background: JSON.parse(window.localStorage['gc_background'] || null),
  currentCover: JSON.parse(window.localStorage['gc_cover'] || null),
  myCovers: [],
  suoneria: JSON.parse(window.localStorage['gc_suoneria'] || null),
  zoom: window.localStorage['gc_zoom'] || '100%',
  volume: parseFloat(window.localStorage['gc_volume']) || 0.5,
  lang: window.localStorage['gc_language'],
  brightness: parseInt(window.localStorage['gc_brightness'] || 75),
  // myImage: window.localStorage['gc_myImage'] || null,
  myImage: null,
  myData: JSON.parse(window.localStorage['gc_myData'] || null),
  // notification: (window.localStorage['gc_notification'] === null || window.localStorage['gc_notification'] === undefined) ? true : window.localStorage['gc_notification'],
  // airplane: (window.localStorage['gc_airplane'] === null || window.localStorage['gc_airplane'] === undefined) ? false : window.localStorage['gc_airplane'],
  notification: true,
  airplane: false,
  brightnessActive: true,
  enableHalfShow: true,
  config: {}
}

const getters = {
  show: ({ show }) => show,
  halfShow: ({halfShow}) => halfShow,
  myPhoneNumber: ({ myPhoneNumber }) => myPhoneNumber,
  volume: ({ volume }) => volume,
  notification: ({ notification }) => notification,
  enableHalfShow: ({ enableHalfShow }) => enableHalfShow,
  airplane: ({ airplane }) => airplane,
  brightnessActive: ({ brightnessActive }) => brightnessActive,
  brightness: ({ brightness }) => brightness,
  myImage: ({ myImage, config }) => myImage,
  myData: ({ myData, config }) => myData,
  background: ({ background, config }) => {
    if (background === null) {
      if (config.background_default !== undefined) {
        return config.background_default
      }
      return { label: 'Default', value: 'apple.png' }
    }
    return background
  },
  backgroundLabel: (state, getters) => getters.background.label,
  backgroundURL: (state, getters) => {
    if (getters.background.value !== undefined) {
      if (getters.background.value.startsWith('http') === true || getters.background.value.startsWith('https') === true) {
        return getters.background.value
      }
    }
    return '/html/static/img/background/' + getters.background.value
  },
  suoneria: ({ suoneria, config }) => {
    if (suoneria === null) {
      if (config && config.suoneria_default !== undefined) {
        return config.suoneria_default
      }
      return { label: 'Panters', value: 'ring.ogg' }
    }
    return suoneria
  },
  currentCover: ({ currentCover, config }) => {
    if (currentCover === null) {
      if (window.localStorage['gc_cover'] !== undefined && window.localStorage['gc_cover'] !== null) {
        return JSON.parse(window.localStorage['gc_cover'])
      }
      return { label: 'Nessuna cover', value: 'base.png' }
    }
    return currentCover
  },
  myCovers: ({ myCovers }) => myCovers,
  suoneriaLabel: (state, getters) => getters.suoneria.label,
  zoom: ({ zoom }) => zoom,
  colors: ({ config }) => config.colors,
  AppsHome: (state, getters) => getters.Apps.filter(app => app.inHomePage === true),
  config: ({ config }) => config,
  Apps: ({ config, lang }, getters) => config.apps
    .filter(app => app.enabled !== false)
    .map(app => {
      if (app.puceRef !== undefined) {
        app.puce = getters[app.puceRef]
      }
      const keyName = `${lang}__name`
      app.intlName = app[keyName] || app.name
      return app
    }
  ),
  availableLanguages ({ config }) {
    const langKey = Object.keys(config.language)
    const AvailableLanguage = {}
    for (const key of langKey) {
      AvailableLanguage[config.language[key].NAME] = {value: key, icons: 'fa-flag'}
    }
    return AvailableLanguage
  },
  LangString ({ config, lang }) {
    return (LABEL) => {
      if (process.env.NODE_ENV !== 'production') return "M_T"
      return config.language[config.langaugeType].data[LABEL] || LABEL
    }
  }
}

const actions = {
  loadConfig ({ commit, state }, { config, language, type }) {
    var timeAgoConf = config.language[type || config.defaultLanguage].TIMEAGO
    if (type) config.langaugeType = type
    if (language) config.language[type].data = language
    if (timeAgoConf !== undefined) Vue.prototype.$timeago.addLocale(type, timeAgoConf)
    Vue.prototype.$timeago.setCurrentLocale(state.lang)
    if (config.defaultContacts !== undefined) commit('SET_DEFAULT_CONTACTS', config.defaultContacts)
    commit('SET_CONFIG', config)
  },
  setVisibility ({ commit }, show) {
    commit('SET_PHONE_VISIBILITY', show)
  },
  setZoom ({ commit }, zoom) {
    window.localStorage['gc_zoom'] = zoom
    commit('SET_ZOOM', zoom)
  },
  setBackground ({ commit }, background) {
    window.localStorage['gc_background'] = JSON.stringify(background)
    commit('SET_BACKGROUND', background)
  },
  setCurrentCover ({ commit }, cover) {
    window.localStorage['gc_cover'] = JSON.stringify(cover)
    commit('SET_CURRENT_COVER', cover)
  },
  setsuoneria ({ commit }, suoneria) {
    window.localStorage['gc_suoneria'] = JSON.stringify(suoneria)
    commit('SET_SUONERIA', suoneria)
  },
  toggleNotifications ({ commit, state }) {
    commit('TOGGLE_NOTIFICATIONS')
    window.localStorage['gc_notification'] = state.notification
    PhoneAPI.updateNotifications(state.notification)
  },
  toggleAirplane ({ commit, state }) {
    commit('TOGGLE_AIRPLANE')
    window.localStorage['gc_airplane'] = state.airplane
    PhoneAPI.updateAirplane(state.airplane)
  },
  setVolume ({ commit }, volume) {
    window.localStorage['gc_volume'] = volume
    commit('SET_VOLUME', volume)
    PhoneAPI.updateVolume({ volume: volume })
  },
  setLanguage ({ commit }, lang) {
    window.localStorage['gc_language'] = lang
    Vue.prototype.$timeago.setCurrentLocale(lang)
    commit('SET_LANGUAGE', lang)
  },
  closePhone () {
    PhoneAPI.closePhone()
  },
  resetPhone ({ dispatch, getters }) {
    dispatch('setZoom', '100%')
    dispatch('setVolume', 1)
    dispatch('setBackground', getters.config.background_default)
    dispatch('setCurrentCover', getters.config.cover_default)
    dispatch('setsuoneria', getters.config.suoneria_default)
    dispatch('setLanguage', 'it_IT')
  },
  sendStartupValues ({ state }) {
    const data = {
      volume: state.volume,
      notification: state.notification,
      cover: state.currentCover,
      airplane: state.airplane,
      twitterSound: localStorage['gcphone_twitter_notif_sound'] === "true",
      twitterNotif: localStorage['gcphone_twitter_notif'] ? JSON.parse(localStorage['gcphone_twitter_notif']) : [true, false, false]
    }
    PhoneAPI.sendStartupValues(data)
  },
  changeBrightness ({ commit }, value) {
    commit('CHANGE_BRIGHTNESS', value)
  }
}

const mutations = {
  SET_CONFIG (state, config) {
    state.config = config
  },
  // SET_APP_ENABLE (state, {appName, enable}) {
  //   const appIndex = state.config.apps.findIndex(app => app.name === appName)
  //   if (appIndex !== -1) {
  //     Vue.set(state.config.apps[appIndex], 'enabled', enable)
  //   }
  // },
  TOGGLE_HALF_SHOW (state, bool) {
    state.enableHalfShow = bool
  },
  SET_HALF_SHOW (state, bool) {
    state.halfShow = state.enableHalfShow ? bool : false
  },
  SET_PHONE_VISIBILITY (state, show) {
    state.show = show
  },
  SET_MY_PHONE_NUMBER (state, myPhoneNumber) {
    state.myPhoneNumber = myPhoneNumber
  },
  SET_BACKGROUND (state, background) {
    state.background = background
  },
  SET_CURRENT_COVER (state, cover) {
    state.currentCover = cover
    // console.log(state.currentCover)
  },
  UPDATE_MY_COVERS (state, data) {
    state.myCovers = data
  },
  SET_SUONERIA (state, suoneria) {
    state.suoneria = suoneria
  },
  SET_ZOOM (state, zoom) {
    state.zoom = zoom
  },
  SET_VOLUME (state, volume) {
    state.volume = volume
  },
  SET_LANGUAGE (state, lang) {
    state.lang = lang
  },
  TOGGLE_NOTIFICATIONS (state) {
    state.notification = !state.notification
  },
  TOGGLE_AIRPLANE (state) {
    state.airplane = !state.airplane
  },
  UPDATE_MY_IMG (state, img) {
    window.localStorage['gc_myImage'] = img
    state.myImage = img
  },
  SEND_INIT_VALUES (state, data) {
    window.localStorage['gc_myData'] = JSON.stringify(data)
    state.myData = data
  },
  CHANGE_BRIGHTNESS (state, value) {
    window.localStorage['gc_brightness'] = parseInt(value)
    state.brightness = parseInt(value)
  },
  CHANGE_BRIGHTNESS_STATE (state, bool) {
    // console.log(bool)
    state.brightnessActive = bool
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  // qui ci andrà l'phoneNumber
  state.myPhoneNumber = 'developer'

  state.myData = {
    job: 'polizia',
    job2: 'ambulanza',
    firstname: 'Sono',
    lastname: 'fikissimo'
  }

  // state.myImage = 'https://i.pinimg.com/originals/a7/78/12/a77812097209861733815253180873ba.jpg'
}
