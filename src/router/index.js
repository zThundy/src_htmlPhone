import Vue from 'vue'
import Router from 'vue-router'

import Home from '@/components/Home'
import Menu from '@/components/Menu'
import Lockscreen from '@/components/Lockscreen'

import Contacts from '@/components/contacts/Contacts'
import Contact from '@/components/contacts/Contact'

import MessagesList from '@/components/messages/MessagesList'
import Messages from '@/components/messages/Messages'
import MessagesContactsInoltra from '@/components/messages/MessagesInoltra'
import MessageContactsSelect from '@/components/messages/MessageContactsSelect'

import Appels from '@/components/Appels/Appels'
import AppelsActive from '@/components/Appels/AppelsActive'
import AppelsNumber from '@/components/Appels/AppelsNumber'

import TchatSplashScreen from '@/components/Tchat/TchatSplashScreen'
import TchatChannel from '@/components/Tchat/TchatChannel'
import TchatMessage from '@/components/Tchat/TchatMessage'

import TwitterSpashScreen from '@/components/twitter/TwitterSpashScreen'
import TwitterScreen from '@/components/twitter/TwitterScreen'

import InstaSpashScreen from '@/components/instagram/InstagramSpashScreen'
import InstaScreen from '@/components/instagram/InstagramScreen'

import Parametre from '@/components/parametre/Parametre'
import Bank from '@/components/Bank/Bank'
import Bourse from '@/components/Bourse/Bourse'
import Photo from '@/components/Photo/Photo'

import dati from '@/components/dati/dati'
import datisplash from '@/components/dati/datisplash'

import whatsapp from '@/components/whatsapp/whatsapp'
import whatsappsplash from '@/components/whatsapp/whatsappsplash'
import whatsappgruppo from '@/components/whatsapp/whatsappgruppo'
import whatsappnewgruppo from '@/components/whatsapp/whatsappnewgroup'
import whatsappgroupedit from '@/components/whatsapp/whatsappgroupedit'

import galleria from '@/components/galleria/galleria'
import galleriasplash from '@/components/galleria/galleriasplash'

Vue.use(Router)

export default new Router({
  routes: [
    {
      // meta: { depth: 0, transitionName: 'slide' },
      path: '/',
      name: 'lockscreen',
      component: Lockscreen
    },
    {
      // meta: { depth: 0, transitionName: 'slide' },
      path: '/home',
      name: 'home',
      component: Home
    },
    {
      meta: { depth: 1, transitionName: 'slide' },
      path: '/menu',
      name: 'menu',
      component: Menu
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/contacts',
      name: 'contacts',
      component: Contacts
    },
    {
      path: '/contact/:id/:number?',
      name: 'contacts.view',
      component: Contact
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/messages',
      name: 'messages',
      component: MessagesList
    },
    {
      path: '/messages/select',
      name: 'messages.selectcontact',
      component: MessageContactsSelect
    },
    {
      path: '/messages/:chooseinoltra',
      name: 'messages.chooseinoltra',
      component: MessagesContactsInoltra
    },
    {
      path: '/messages/:number/:display',
      name: 'messages.view',
      component: Messages
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/bourse',
      name: 'bourse',
      component: Bourse
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/dati',
      name: 'dati',
      component: dati
    },
    {
      path: '/dati/splash',
      name: 'dati.splash',
      component: datisplash
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/bank',
      name: 'bank',
      component: Bank
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/photo',
      name: 'photo',
      component: Photo
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/paramtre',
      name: 'parametre',
      component: Parametre
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/appels',
      name: 'appels',
      component: Appels
    },
    {
      path: '/appelsactive',
      name: 'appels.active',
      component: AppelsActive
    },
    {
      path: '/appelsNumber',
      name: 'appels.number',
      component: AppelsNumber
    },
    {
      path: '/tchatsplash',
      name: 'tchat',
      component: TchatSplashScreen
    },
    {
      meta: { depth: 2 },
      path: '/tchat',
      name: 'tchat.channel',
      component: TchatChannel
    },
    {
      path: '/tchat/:channel',
      name: 'tchat.channel.show',
      component: TchatMessage
    },
    {
      path: '/twitter/splash',
      name: 'twitter.splash',
      component: TwitterSpashScreen
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/twitter/view',
      name: 'twitter.screen',
      component: TwitterScreen
    },
    {
      path: '/instagram/splash',
      name: 'instagram.splash',
      component: InstaSpashScreen
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/instagram/view',
      name: 'instagram.screen',
      component: InstaScreen
    },
    {
      path: '/whatsapp/splash',
      name: 'whatsapp.splash',
      component: whatsappsplash
    },
    {
      path: '/whatsapp/gruppo',
      name: 'whatsapp.gruppo',
      component: whatsappgruppo
    },
    {
      path: '/whatsapp/newgruppo',
      name: 'whatsapp.newgruppo',
      component: whatsappnewgruppo
    },
    {
      path: '/whatsapp/whatsappgroupedit',
      name: 'whatsapp.editgroup',
      component: whatsappgroupedit
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/whatsapp',
      name: 'whatsapp',
      component: whatsapp
    },
    {
      meta: { depth: 2, transitionName: 'slide' },
      path: '/galleria',
      name: 'galleria',
      component: galleria
    },
    {
      meta: { depth: 1, transitionName: 'slide' },
      path: '/galleria/splash',
      name: 'galleria.splash',
      component: galleriasplash
    },
    {
      path: '*',
      redirect: '/'
    }
  ]
})
