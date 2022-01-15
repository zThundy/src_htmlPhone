import PhoneAPI from './../../PhoneAPI'
import Vue from 'vue'

const state = {
  twitterNotification: localStorage['gcphone_twitter_notif'] ? JSON.parse(localStorage['gcphone_twitter_notif']) : [true, false, false],
  twitterNotificationSound: localStorage['gcphone_twitter_notif_sound'] || "true",
  tweets: [],
  favoriteTweets: [],
  account: {
    username: localStorage['gcphone_twitter_username'] || "",
    password: localStorage['gcphone_twitter_password'] || "",
    passwordConfirm: "",
    avatarUrl: localStorage['gcphone_twitter_avatarUrl'] || "/html/static/img/app_twitter/default_profile.png"
  },
}

const getters = {
  twitterNotification: ({ twitterNotification }) => twitterNotification,
  twitterNotificationSound: ({ twitterNotificationSound }) => {
    if (twitterNotificationSound === "true") return true
    return false
  },
  tweets: ({ tweets }) => tweets,
  favoriteTweets: ({ favoriteTweets }) => favoriteTweets,
  account: ({ account }) => account,
}

const actions = {
  twitterLogout ({ dispatch }) {
    localStorage.removeItem('gcphone_twitter_username')
    localStorage.removeItem('gcphone_twitter_password')
    localStorage.removeItem('gcphone_twitter_avatarUrl')
    dispatch("setAccount", { username: "", password: "", avatarUrl: "/html/static/img/app_twitter/default_profile.png", passwordConfirm: "" })
  },
  twitterPostTweet ({ state, commit }, { message }) {
    PhoneAPI.twitter_postTweet(state.account.username, state.account.password, PhoneAPI.convertEmoji(message))
  },
  twitterToogleLike ({ state }, { tweetId }) {
    PhoneAPI.twitter_toggleLikeTweet(state.account.username, state.account.password, tweetId)
  },
  setAccount ({ commit }, data) {
    if (!data.username) data.username = localStorage['gcphone_twitter_username'] || ""
    if (!data.password) data.password = localStorage['gcphone_twitter_password'] || ""
    if (!data.avatarUrl) data.avatarUrl = localStorage['gcphone_twitter_avatarUrl'] || "/html/static/img/app_twitter/default_profile.png"
    localStorage['gcphone_twitter_username'] = data.username
    localStorage['gcphone_twitter_password'] = data.password
    localStorage['gcphone_twitter_avatarUrl'] = data.avatarUrl
    commit('UPDATE_ACCOUNT', data)
    if (data.passwordConfirm) commit("SET_PASSWORD_CONFIRM", data.passwordConfirm)
  },
  addTweet ({ commit, state }, { tweet, sourceAuthor }) {
    let index = state.twitterNotification.indexOf(true)
    let notifications = index === 0
    // check if message contains a mention
    if (!notifications && index === 1) { notifications = tweet.message && tweet.message.toLowerCase().indexOf(state.account.username.toLowerCase()) !== -1 }
    // if notification is true then show a notification
    if (notifications) {
      PhoneAPI.ongenericNotification({
        message: tweet.message,
        title: tweet.author,
        icon: 'twitter',
        color: 'rgb(80, 160, 230)',
        sound: state.twitterNotificationSound === "true" ? 'Twitter_Sound_Effect.ogg' : undefined,
        appName: 'Twitter'
      })
    }
    commit('ADD_TWEET', { tweet })
  },
  fetchFavoriteTweets ({ state }) {
    PhoneAPI.twitter_getFavoriteTweets(state.account.username, state.account.password)
  },
  setTwitterNotification ({ commit }, value) {
    localStorage['gcphone_twitter_notif'] = JSON.stringify(value)
    commit('SET_TWITTER_NOTIFICATION', { notification: value })
  },
  setTwitterNotificationSound ({ commit }, value) {
    value = String(value)
    localStorage['gcphone_twitter_notif_sound'] = value
    commit('SET_TWITTER_NOTIFICATION_SOUND', { notificationSound: value })
  }
}

const mutations = {
  SET_TWITTER_NOTIFICATION (state, { notification }) {
    state.twitterNotification = notification
  },
  SET_TWITTER_NOTIFICATION_SOUND (state, { notificationSound }) {
    state.twitterNotificationSound = notificationSound
  },
  UPDATE_ACCOUNT (state, { username, password, avatarUrl }) {
    state.account.username = username
    state.account.password = password
    state.account.avatarUrl = avatarUrl
  },
  SET_PASSWORD_CONFIRM (state, pass) {
    state.account.passwordConfirm = pass
  },
  SET_TWEETS (state, { tweets }) {
    state.tweets = tweets
  },
  SET_FAVORITE_TWEETS (state, { tweets }) {
    state.favoriteTweets = tweets
  },
  ADD_TWEET (state, { tweet }) {
    state.tweets = [tweet, ...state.tweets]
  },
  UPDATE_TWEET_LIKE (state, { tweetId, likes }) {
    const tweetIndex = state.tweets.findIndex(t => t.id === tweetId)
    if (tweetIndex !== -1) state.tweets[tweetIndex].likes = likes
    const tweetIndexFav = state.favoriteTweets.findIndex(t => t.id === tweetId)
    if (tweetIndexFav !== -1) state.favoriteTweets[tweetIndexFav].likes = likes
  },
  UPDATE_TWEET_ISLIKE (state, { tweetId, has_like }) {
    const tweetIndex = state.tweets.findIndex(t => t.id === tweetId)
    if (tweetIndex !== -1) Vue.set(state.tweets[tweetIndex], 'has_like', has_like)
    const tweetIndexFav = state.favoriteTweets.findIndex(t => t.id === tweetId)
    if (tweetIndexFav !== -1) Vue.set(state.favoriteTweets[tweetIndexFav], 'has_like', has_like)
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  state.account = {
    username: "dev1234",
    password: "dev1234",
    passwordConfirm: "dev1234",
    avatarUrl: "/html/static/img/app_twitter/default_profile.png"
  }
  state.favoriteTweets = [{
    id: 1,
    message: 'questo è il primo messaggio di twitter :aureola: :aureola: :aureola: :aureola: :aureola:',
    author: 'Gannon',
    time: new Date(),
    likes: 3,
    has_like: 60
  }, {
    id: 2,
    message: 'Borderlands 3 arrives on Xbox One, PS4, and PC on September 13, 2019! Tune in to the Gameplay Reveal Event on May 1st, where we’ll debut the first hands-on looks! Pre-order now to get the Gold Weapon Skins Pack! ➜ https://borderlands.com  ',
    author: 'Gearbox Official',
    authorIcon: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
    time: new Date(),
    likes: 65
  }, {
    id: 3,
    message: 'https://wallpaperaccess.com/full/109672.jpg',
    img: 'https://wallpaperaccess.com/full/109672.jpg',
    author: 'Gannon',
    likes: 0,
    time: new Date()
  }, {
    id: 4,
    message: 'Super Message de la mort.',
    author: 'Gannon',
    authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
    likes: 0,
    time: new Date()
  },
  {
    id: 5,
    message: 'Super Message de la mort.',
    author: 'Gannon',
    authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
    likes: 0,
    time: new Date()
  }
  // },
  // {
  //   id: 6,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // },
  // {
  //   id: 7,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // },
  // {
  //   id: 8,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // }]
  // state.tweets = [{
  //   id: 1,
  //   message: 'questo è il primo messaggio di twitter :grinning: :grinning: :grinning: :grinning: :grinning: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl: :rofl:',
  //   author: 'Gannon',
  //   time: new Date(),
  //   likes: 3,
  //   has_like: 60
  // }, {
  //   id: 2,
  //   message: 'Borderlands 3 arrives on Xbox One, PS4, and PC on September 13, 2019! Tune in to the Gameplay Reveal Event on May 1st, where we’ll debut the first hands-on looks! Pre-order now to get the Gold Weapon Skins Pack! ➜ https://borderlands.com  ',
  //   author: 'Gearbox Official',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
  //   time: new Date(),
  //   likes: 65
  // }, {
  //   id: 3,
  //   message: 'https://wallpaperaccess.com/full/109672.jpg',
  //   img: 'https://cdn.discordapp.com/attachments/563443658192322576/563473765569396746/samurai-background-hd-1920x1200-45462.jpg',
  //   author: 'Gannon',
  //   likes: 0,
  //   time: new Date()
  // }, {
  //   id: 4,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // },
  // {
  //   id: 5,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // },
  // {
  //   id: 6,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // },
  // {
  //   id: 7,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // },
  // {
  //   id: 8,
  //   message: 'Super Message de la mort.',
  //   author: 'Gannon',
  //   authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
  //   likes: 0,
  //   time: new Date()
  // }
  ]
  // state.tweets = []
}
