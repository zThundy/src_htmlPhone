// import PhoneAPI from './../../PhoneAPI'
// import config from '../../../static/config/config'

const state = {
  news: JSON.parse(window.localStorage['gc_savednews'] || null),
  job: null
}

const getters = {
  news: ({ news }) => news,
  job: ({ job }) => job
}

const actions = { }

const mutations = {
  UPDATE_NEWS (state, news) {
    window.localStorage['gc_savednews'] = JSON.stringify(news)
    state.news = news
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  const time = new Date().getTime()
  state.job = 'reporter'
  state.news = [
    {
      message: 'Questo è un messaggio di prova Questo è un messagmessaggio di prova Questo è un messaggio di prova Questo è un messaggio di prova',
      pics: [
        'https://u.trs.tn/tohqw.jpg',
        'https://image.shutterstock.com/image-vector/illustration-stylized-character-measuring-his-260nw-38124655.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Height_demonstration_diagram.png/200px-Height_demonstration_diagram.png',
        'https://i.imgur.com/1YgvLHK.jpg'
      ],
      time: time
    },
    {
      message: 'Questo è un messaggio di prova Questo è un messagmessaggio di prova Questo è un messaggio di prova Questo è un messaggio di prova',
      pics: [
        'https://u.trs.tn/tohqw.jpg',
        'https://image.shutterstock.com/image-vector/illustration-stylized-character-measuring-his-260nw-38124655.jpg',
        'https://i.redd.it/u105ro5rg8o31.jpg',
        'https://i.pinimg.com/originals/ec/1c/a7/ec1ca71b815a418adf58128f47269e10.jpg'
      ],
      time: time
    },
    {
      message: 'Questo è un messaggio di prova Questo è un messagmessaggio di prova Questo è un messaggio di prova Questo è un messaggio di prova',
      pics: [
        'https://i.pinimg.com/originals/ec/1c/a7/ec1ca71b815a418adf58128f47269e10.jpg',
        'https://i.redd.it/u105ro5rg8o31.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Height_demonstration_diagram.png/200px-Height_demonstration_diagram.png',
        'https://i.imgur.com/1YgvLHK.jpg'
      ],
      time: time
    },
    {
      message: 'Questo è un messaggio di prova Questo è un messagmessaggio di prova Questo è un messaggio di prova Questo è un messaggio di prova',
      pics: [],
      time: time
    },
    {
      message: '',
      pics: [
        'https://i.pinimg.com/originals/ec/1c/a7/ec1ca71b815a418adf58128f47269e10.jpg',
        'https://i.redd.it/u105ro5rg8o31.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Height_demonstration_diagram.png/200px-Height_demonstration_diagram.png',
        'https://i.imgur.com/1YgvLHK.jpg'
      ],
      time: time
    }
  ]
}
