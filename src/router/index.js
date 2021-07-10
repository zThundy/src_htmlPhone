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

import Settings from '@/components/settings/Settings'
import Photo from '@/components/Photo/Photo'

import Borsa from '@/components/Borsa/Borsa'
import BorsaSplash from '@/components/Borsa/BorsaSplash'

import Bank from '@/components/Bank/Bank'
import BankSplash from '@/components/Bank/BankSplash'

import dati from '@/components/dati/dati'
import datisplash from '@/components/dati/datisplash'

import whatsapp from '@/components/whatsapp/whatsapp'
import whatsappsplash from '@/components/whatsapp/whatsappsplash'
import whatsappgruppo from '@/components/whatsapp/whatsappgruppo'
import whatsappnewgruppo from '@/components/whatsapp/whatsappnewgroup'
import whatsappgroupedit from '@/components/whatsapp/whatsappgroupedit'

import galleria from '@/components/galleria/galleria'
import galleriasplash from '@/components/galleria/galleriasplash'

import DarkwebSplash from '@/components/darkweb/DarkwebSplash'
import DarkwebScreen from '@/components/darkweb/DarkwebScreen'

import Email from '@/components/email/email'
import EmailSplash from '@/components/email/emailsplash'
import EmailView from '@/components/email/emailview'
import EmailWrite from '@/components/email/emailwrite'
import EmailChooseContact from '@/components/email/emailchoosecontact'
import EmailRegister from '@/components/email/emailregister'

import News from '@/components/news/news'
import NewsSplash from '@/components/news/newssplash'

import Azienda from '@/components/azienda/azienda'
import AziendaSplash from '@/components/azienda/aziendasplash'

import Emoji from '@/components/emoji/emoji'
import EmojiSplash from '@/components/emoji/emojisplash'

import Calculator from '@/components/calculator/calculator'
import CalculatorSplash from '@/components/calculator/calculatorsplash'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'lockscreen',
      component: Lockscreen
    },
    {
      path: '/home',
      name: 'home',
      component: Home
    },
    {
      path: '/menu',
      name: 'menu',
      component: Menu
    },
    {
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
      path: '/borsa',
      name: 'borsa',
      component: Borsa
    },
    {
      path: '/borsasplash',
      name: 'borsa.splash',
      component: BorsaSplash
    },
    {
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
      path: '/bank',
      name: 'bank',
      component: Bank
    },
    {
      path: '/banksplash',
      name: 'bank.splash',
      component: BankSplash
    },
    {
      path: '/photo',
      name: 'photo',
      component: Photo
    },
    {
      path: '/paramtre',
      name: 'settings',
      component: Settings
    },
    {
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
      path: '/whatsapp',
      name: 'whatsapp',
      component: whatsapp
    },
    {
      path: '/galleria',
      name: 'galleria',
      component: galleria
    },
    {
      path: '/galleria/splash',
      name: 'galleria.splash',
      component: galleriasplash
    },
    {
      path: '/darkweb/splash',
      name: 'darkweb.splash',
      component: DarkwebSplash
    },
    {
      path: '/darkweb/view',
      name: 'darkweb.screen',
      component: DarkwebScreen
    },
    {
      path: '/email',
      name: 'email',
      component: Email
    },
    {
      path: '/email/splash',
      name: 'email.splash',
      component: EmailSplash
    },
    {
      path: '/email/register',
      name: 'email.register',
      component: EmailRegister
    },
    {
      path: '/email/view',
      name: 'email.view',
      component: EmailView
    },
    {
      path: '/email/write',
      name: 'email.write',
      component: EmailWrite
    },
    {
      path: '/email/choosecontact',
      name: 'email.choosecontact',
      component: EmailChooseContact
    },
    {
      path: '/news',
      name: 'news',
      component: News
    },
    {
      path: '/news/splash',
      name: 'news.splash',
      component: NewsSplash
    },
    {
      path: '/azienda',
      name: 'azienda',
      component: Azienda
    },
    {
      path: '/azienda/splash',
      name: 'azienda.splash',
      component: AziendaSplash
    },
    {
      path: '/emoji/splash',
      name: 'emoji.splash',
      component: EmojiSplash
    },
    {
      path: '/emoji',
      name: 'emoji',
      component: Emoji
    },
    {
      path: '/calculator/splash',
      name: 'calculator.splash',
      component: CalculatorSplash
    },
    {
      path: '/calculator',
      name: 'calculator',
      component: Calculator
    },
    {
      path: '*',
      redirect: '/'
    }
  ]
})
