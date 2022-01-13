<template>
  <div>
    <div class="groupCheckBoxTitle">
      <label>{{ LangString('APP_TWITTER_NOTIFICATION_WHEN') }}</label>
    </div>

    <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(2)">
      <input type="checkbox" :checked="twitterNotification === 2" @click.prevent.stop="setNotification(2)">
      <span>{{ LangString('APP_TWITTER_NOTIFICATION_ALL') }}</span>
    </label>

    <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(1)">
      <input type="checkbox" :checked="twitterNotification === 1" @click.prevent.stop="setNotification(1)">
      <span>{{ LangString('APP_TWITTER_NOTIFICATION_MENTION') }}</span>
    </label>

    <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(0)">
      <input type="checkbox" :checked="twitterNotification === 0" @click.prevent.stop="setNotification(0)">
      <span>{{ LangString('APP_TWITTER_NOTIFICATION_NEVER') }}</span>
    </label>

    <div class="groupCheckBoxTitle">
      <label>{{ LangString('APP_TWITTER_NOTIFICATION_SOUND') }}</label>
    </div>

    <label class="group checkbox" data-type="button" @click.prevent.stop="setNotificationSound(true)">
      <input type="checkbox" :checked="twitterNotificationSound" @click.prevent.stop="setNotificationSound(true)">
      <span>{{ LangString('APP_TWITTER_NOTIFICATION_SOUND_YES') }}</span>
    </label>

    <label class="group checkbox" data-type="button" @click.prevent.stop="setNotificationSound(false)">
      <input type="checkbox" :checked="!twitterNotificationSound" @click.prevent.stop="setNotificationSound(false)">
      <span>{{ LangString('APP_TWITTER_NOTIFICATION_SOUND_NO') }}</span>
    </label>
  </div>
</template>