// import PhoneAPI from './../../PhoneAPI'
import config from '../../../static/config/config'

const state = {
  config: config,
  lang: window.localStorage['gc_language'],
  downloadableApps: JSON.parse(window.localStorage['gc_downloadable_app'] || null),
  downloadedApps: JSON.parse(window.localStorage['gc_downloadedapp_app'] || null) || []
}

const getters = {
  downloadableApps: ({ config, lang, downloadableApps, downloadedApps }) => config.apps
    .filter(app => app.enabled === false)
    .map((app, key) => {
      app.intlName = app[`${lang}__name`] || app.name
      if (downloadedApps[key]) {
        app.enabled = true
        // commit('APP_SUCCESFULLY_DOWNLOADED', { app: app, identifier: key })
      }
      return app
    }
  )
}

const actions = {
  setupApps ({ commit }, apps) {
    commit('SETUP_APPSTORE_APPS', apps)
  },
  installApp ({ commit }, data) {
    commit('APP_SUCCESFULLY_DOWNLOADED', data)
  }
}

const mutations = {
  SETUP_APPSTORE_APPS (state, apps) {
    for (var i in apps) {
      if (apps[i].downloaded === undefined || apps[i].downloaded === null) {
        apps[i].downloaded = false
      }
    }
    state.downloadableApps = apps
    window.localStorage['gc_downloadable_app'] = JSON.stringify(apps)
  },
  APP_SUCCESFULLY_DOWNLOADED (state, data) {
    state.downloadableApps[data.identifier] = null
    console.log(state.downloadedApps)
    state.downloadedApps[data.app.name] = data.app
    console.log(state.downloadedApps)
    window.localStorage['gc_downloadedapp_app'] = JSON.stringify(state.downloadedApps)
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  console.log(state.downloadedApps)
}
