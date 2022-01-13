<template>
  <div>
    <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button" @click.stop="onPressChangeAvartar">
      <img :src="twitterAvatarUrl" style="height: 64px; width: 64px;" @click.stop="onPressChangeAvartar">
      <input type='button' style="width: 170px;" class="btn btn-blue" :value="LangString('APP_TWITTER_ACCOUNT_AVATAR')" @click.stop="onPressChangeAvartar" />
    </div>

    <div class="group" data-type="button" @click.stop="changePassword">
      <input type='button' class="btn btn-red" :value="LangString('APP_TWITTER_ACCOUNT_CHANGE_PASSWORD')" @click.stop="changePassword"/>
    </div>
  </div>
</template>