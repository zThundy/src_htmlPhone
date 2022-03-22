import Vue from 'vue'

const state = {
  tempImage: '',
  instagramNotification: localStorage['gp_ig_notif'] ? JSON.parse(localStorage['gp_ig_notif']) : [true, false, false],
  instagramNotificationSound: localStorage['gp_ig_notif_sound'] || "true",
  instaPosts: [],
  likedInstas: [],
  igAccount: {
    username: localStorage["gp_ig_username"] || "",
    password: localStorage["gp_ig_password"] || "",
    avatarUrl: localStorage['gp_ig_avatarUrl'] || "/html/static/img/app_instagram/default_profile.png",
    passwordConfirm: "",
    logged: false
  }
}

const getters = {
  tempImage: ({ tempImage }) => tempImage,
  igAccount: ({ igAccount }) => igAccount,
  instagramNotification: ({ instagramNotification }) => instagramNotification,
  instagramNotificationSound: ({ instagramNotificationSound }) => {
    if (instagramNotificationSound === "true") return true
    return false
  },
  instaPosts: ({ instaPosts }) => instaPosts
}

const actions = {
  // salvataggio immagine temporanea per post twitter
  instagramSaveTempPost ({ commit }, url) {
    commit('SAVE_TEMP_POST_PIC', url)
  },
  // questa funzione pulisce gli state interni dello storage locale
  // per permetterti di loggare su insta da un altro account
  instagramLogout ({ dispatch }) {
    dispatch("setInstagramAccount", { username: "", password: "", avatarUrl: "/html/static/img/app_twitter/default_profile.png", passwordConfirm: "", logged: false })
    localStorage.removeItem('gp_ig_username')
    localStorage.removeItem('gp_ig_password')
    localStorage.removeItem('gp_ig_avatarUrl')
  },
  // questo imposta i valori a prescindere da dove vengono
  setInstagramAccount ({ commit }, data) {
    if (!data.username) data.username = localStorage['gp_ig_username'] || ""
    if (!data.password) data.password = localStorage['gp_ig_password'] || ""
    if (!data.avatarUrl) data.avatarUrl = localStorage['gp_ig_avatarUrl'] || "/html/static/img/app_instagram/default_profile.png"
    localStorage['gp_ig_username'] = data.username
    localStorage['gp_ig_password'] = data.password
    localStorage['gp_ig_avatarUrl'] = data.avatarUrl
    commit('UPDATE_INSTAGRAM_ACCOUNT', data)
  },
  setInstagramNotification ({ commit }, value) {
    localStorage['gp_ig_notif'] = JSON.stringify(value)
    commit('SET_INSTAGRAM_NOTIFICATION', { notification: value })
  },
  setInstagramNotificationSound ({ commit }, value) {
    value = String(value)
    localStorage['gp_ig_notif_sound'] = value
    commit('SET_INSTAGRAM_NOTIFICATION_SOUND', { notificationSound: value })
  }
}

const mutations = {
  UPDATE_INSTAGRAM_ACCOUNT (state, data) {
    state.igAccount.username = data.username
    state.igAccount.password = data.password
    state.igAccount.avatarUrl = data.avatarUrl
    if (data.passwordConfirm) state.igAccount.passwordConfirm = data.passwordConfirm
    if (data.logged !== null && data.logged !== undefined) state.igAccount.logged = data.logged
  },
  SET_POSTS (state, { posts }) {
    state.instaPosts = posts
  },
  SET_INSTAGRAM_NOTIFICATION (state, { notification }) {
    state.instagramNotification = notification
  },
  SET_INSTAGRAM_NOTIFICATION_SOUND (state, { notificationSound }) {
    state.instagramNotificationSound = notificationSound
  },
  UPDATE_POST_LIKES (state, { postId, likes }) {
    const instagramIndex = state.instaPosts.findIndex(t => t.id === postId)
    if (instagramIndex !== -1) {
      state.instaPosts[instagramIndex].likes = likes
    }
  },
  UPDATE_POST_ISLIKE (state, { postId, isLike }) {
    const instagramIndex = state.instaPosts.findIndex(t => t.id === postId)
    if (instagramIndex !== -1) {
      Vue.set(state.instaPosts[instagramIndex], 'isLike', isLike)
    }
  },
  SAVE_TEMP_POST_PIC (state, url) {
    state.tempImage = url
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  let data = new Date().getTime()
  state.instagramAvatarUrl = '/html/static/img/app_instagram/default_profile.png'
  state.tempImage = 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg'
  state.instaPosts = [{
    id: 1,
    image: 'https://i.imgur.com/AwpBPXO.jpg',
    author: 'Gannon',
    data,
    didascalia: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema :rofl:',
    likes: 3,
    filter: 'moon',
    isLike: 1
  }, {
    id: 2,
    image: 'https://i.imgur.com/AwpBPXO.jpg',
    author: 'Gearbox Official',
    authorIcon: 'https://i.imgur.com/8hMQzlk.jpg',
    data,
    didascalia: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema',
    filter: 'Originale',
    likes: 61
  }, {
    id: 3,
    image: 'https://i.imgur.com/8hMQzlk.jpg',
    author: 'Gearbox Official',
    authorIcon: 'https://i.imgur.com/o0Yciqc.jpg',
    data,
    didascalia: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema',
    filter: 'Originale',
    likes: 43
  }, {
    id: 4,
    image: 'https://i.imgur.com/o0Yciqc.jpg',
    author: 'Gearbox Official',
    authorIcon: 'https://i.imgur.com/Zp6i4CB.jpg',
    data,
    didascalia: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema',
    filter: 'moon',
    likes: 21
  }]
}
