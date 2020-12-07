import PhoneAPI from './../../PhoneAPI'
import Vue from 'vue'

const state = {
  tempImage: '',
  instagramUsername: localStorage['gp_ig_username'],
  instagramPassword: localStorage['gp_ig_password'],
  instagramAvatarUrl: localStorage['gp_ig_avatarUrl'],
  instagramNotification: localStorage['gp_ig_notif'] ? parseInt(localStorage['gp_ig_notif']) : 2,
  instagramNotificationSound: localStorage['gp_ig_notif_sound'] !== 'false',
  instaPosts: [],
  likedInstas: []
}

const getters = {
  tempImage: ({ tempImage }) => tempImage,
  instagramUsername: ({ instagramUsername }) => instagramUsername,
  instagramPassword: ({ instagramPassword }) => instagramPassword,
  instagramAvatarUrl: ({ instagramAvatarUrl }) => instagramAvatarUrl,
  instagramNotification: ({ instagramNotification }) => instagramNotification,
  instagramNotificationSound: ({ instagramNotificationSound }) => instagramNotificationSound,
  instaPosts: ({ instaPosts }) => instaPosts
}

const actions = {
  // salvataggio immagine temporanea per post twitter
  instagramSaveTempPost ({ state }, url) {
    state.tempImage = url
  },
  // selezione del filtro e della didascalia da mandare al client
  // del gcphone
  instagramPostImage ({ state }, imageTable) {
    let notif = state.instagramNotification === 2
    if (state.instagramNotification === 1) {
      notif = imageTable.image && imageTable.message.toLowerCase().indexOf(state.instagramUsername.toLowerCase()) !== -1
    }
    if (notif === true) {
      Vue.notify({
        message: 'Ha pubblicato un nuovo post!',
        title: imageTable.author,
        icon: 'instagram',
        backgroundColor: '#FF66FF80',
        sound: state.instagramNotificationSound ? 'Instagram_Notification.ogg' : undefined
      })
    }
    PhoneAPI.instagram_postImage(state.instagramUsername, state.instagramPassword, imageTable)
  },
  // questa è l'ultima funzione che aggiunge effettivamente il
  // post su nui
  instagramNewPostFinale ({ commit }, post) {
    commit('ADD_POST', { post })
  },
  // questa funzione ti permette di creare un nuovo account
  instagramCreateNewAccount (_, {username, password, avatarUrl}) {
    PhoneAPI.instagram_createAccount(username, password, avatarUrl)
  },
  // questa funzione ti permette di loggarti in un account esistente: manda la richiesta
  // al database, la risposta torna su "setInstagramAccount" e ti logga dentro l'app
  instagramLogin (_, { username, password }) {
    PhoneAPI.instagram_login(username, password)
  },
  instagramChangePassword ({ state }, newPassword) {
    state.instagramPassword = newPassword
    PhoneAPI.instagram_changePassword(state.instagramUsername, state.instagramPassword, newPassword)
  },
  // questa funzione pulisce gli state interni dello storage locale
  // per permetterti di loggare su insta da un altro account
  instagramLogout ({ commit }) {
    localStorage.removeItem('gp_ig_username')
    localStorage.removeItem('gp_ig_password')
    localStorage.removeItem('gp_ig_avatarUrl')
    commit('UPDATE_INSTAGRAM_ACCOUNT', { username: undefined, password: undefined, avatarUrl: undefined })
  },
  // questo imposta i valori a prescindere da dove vengono
  setInstagramAccount ({ commit }, data) {
    localStorage['gp_ig_username'] = data.username
    localStorage['gp_ig_password'] = data.password
    localStorage['gp_ig_avatarUrl'] = data.avatarUrl
    commit('UPDATE_INSTAGRAM_ACCOUNT', data)
  },
  instagramSetAvatar ({ state }, { avatarUrl }) {
    state.instagramAvatarUrl = avatarUrl
    PhoneAPI.instagram_setAvatar(state.instagramUsername, state.instagramPassword, avatarUrl)
  },
  instagramToogleLike ({ state }, postId) {
    PhoneAPI.instagram_toggleLikePost(state.instagramUsername, state.instagramPassword, postId)
  },
  setInstagramNotification ({ commit }, value) {
    localStorage['gp_ig_notif'] = value
    commit('SET_TWITTER_NOTIFICATION', { notification: value })
  },
  setInstagramNotificationSound ({ commit }, value) {
    localStorage['gp_ig_notif_sound'] = value
    commit('SET_TWITTER_NOTIFICATION_SOUND', { notificationSound: value })
  }
}

const mutations = {
  // mutuation dell'account di twitter in risposta
  // all'action "setInstagramAccount" o "instagramLogout"
  // sunto: UPDATE DIRETTO DELL'HTML
  UPDATE_INSTAGRAM_ACCOUNT (state, { username, password, avatarUrl }) {
    state.instagramUsername = username
    state.instagramPassword = password
    state.instagramAvatarUrl = avatarUrl
  },
  // questa funzione è quella che riceve i post dal database
  // successivamente alla chiamata di "fetchPosts"
  SET_POSTS (state, { posts }) {
    state.instaPosts = posts
  },
  SET_TWITTER_NOTIFICATION (state, { notification }) {
    state.instagramNotification = notification
  },
  SET_TWITTER_NOTIFICATION_SOUND (state, { notificationSound }) {
    state.instagramNotificationSound = notificationSound
  },
  ADD_POST (state, { instaPost }) {
    state.instaPosts = [instaPost, ...state.instaPosts]
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
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.instagramAvatarUrl = '/html/static/img/app_instagram/default_profile.png'
  state.tempImage = 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg'
  state.instaPosts = [{
    id: 1,
    message: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
    author: 'Gannon',
    time: new Date(),
    description: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema',
    likes: 3,
    filter: 'moon',
    isLike: 1
  }, {
    id: 2,
    message: 'https://images.alphacoders.com/943/thumb-1920-943148.jpg',
    author: 'Gearbox Official',
    authorIcon: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
    time: new Date(),
    description: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema',
    filter: 'Originale',
    likes: 61
  }, {
    id: 3,
    message: 'https://images.alphacoders.com/943/thumb-1920-943148.jpg',
    author: 'Gearbox Official',
    authorIcon: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
    time: new Date(),
    description: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema',
    filter: 'Originale',
    likes: 43
  }, {
    id: 4,
    message: 'https://images.alphacoders.com/943/thumb-1920-943148.jpg',
    author: 'Gearbox Official',
    authorIcon: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
    time: new Date(),
    description: 'Questo testo è una prova. Da qua sto testando cosa succede se scrivi un cazzo di poema',
    filter: 'moon',
    likes: 21
  }]
}
