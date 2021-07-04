<template>
    <button v-bind:class="[{icon: displaySettings.play.displayAsIcon}, globalClasses, displaySettings.play.classes]" v-bind:style="globalStyles, displaySettings.play.style" v-on:click="speak" v-if="displaySettings.play.show">
        <i :class="displaySettings.play.icons"></i> {{{ displaySettings.play.text }}}
    </button>

    <button :class="[{icon: displaySettings.stop.displayAsIcon}, globalClasses, displaySettings.stop.classes]" v-bind:style="globalStyles,displaySettings.stop.style" v-on:click="stop" v-if="displaySettings.stop.show"><i :class="displaySettings.stop.icons"></i> {{ displaySettings.stop.text }} </button>
    <button :class="[{icon: displaySettings.pause.displayAsIcon}, globalClasses, displaySettings.pause.classes]" v-bind:style="globalStyles,displaySettings.pause.style" v-on:click="pause" v-if="displaySettings.pause.show"><i :class="displaySettings.pause.icons"></i> {{ displaySettings.pause.text } }</button>
</template>

<script>
export default {
    props: ['text', 'lang', 'rate', 'pitch', 'voice', 'settings', 'classes', 'styles'],
    ready: function() {
        var self = this
        this.pause = false
        //this.$set('btnText', this.text)
        this.$set('globalClasses', this.classes)
        this.$set('globalStyles', this.styles)
        this.$set('displaySettings.play', $.extend(this.displaySettings.play, this.settings.play))
        this.$set('displaySettings.stop', $.extend(this.displaySettings.stop, this.settings.stop))
        this.$set('displaySettings.pause', $.extend(this.displaySettings.pause, this.settings.pause))
        this.utterance = new SpeechSynthesisUtterance()
        this.words = []
        this.getVoices()
        this.initSpeak()
        // Chrome loads voices asynchronously.
        window.speechSynthesis.onvoiceschanged = function(e) {
            self.getVoices()
        }
        console.log('ready')
    },
    methods: {
        speak() {
        	console.log('speak')
            var self = this
            this.initSpeak()
            this.utterance.text = this.text
            this.utterance.pitch = this.pitch
            this.utterance.voice = (this.voice == undefined) ? this.getVoiceByLanguage() : this.voice
            this.utterance.rate = (this.rate == undefined) ? 1 : this.rate
            this.utterance.onstart = function() {
                self.notifyStart()
            }
            this.utterance.onend = function() {
                console.log("ended")
                self.notifyStop()
            }
            var i = 0
            var words = self.utterance.text.split(" ")
            var charIndex = -1
            console.log(this.utterance)
            if (this.pause) {
                this.pause = true
                this.resume()
            } else {
                console.log(this.utterance)
                window.speechSynthesis.speak(this.utterance)
            }
            this.utterance.onboundary = function(e) {
                console.log('BOUNDARY')
                if (e.name == "word") {
                    if (charIndex !== e.charIndex) {
                        charIndex = e.charIndex
                        self.notifyWord(i)
                        i += 1
                    } else {
                        console.log(e)
                    }
                }
            }
        },
        initSpeak() {
            this.words = this.text.split(" ")
            this.notifyformattedText()
        },
        track() {
            console.log(this.utterance.text)
        },
        stop() {
            window.speechSynthesis.cancel(this.utterance)
            this.notifyStop()
        },
        pause() {
            this.pause = true
            window.speechSynthesis.pause(this.utterance)
        },
        resume() {
            window.speechSynthesis.resume(this.utterance)
        },
        getVoiceByLanguage() {
            var self = this
            for (var key in this.voices) {
                if (this.voices[key].lang == self.lang) {
                    return this.voices[key]
                }
            }
            return this.voices[0]
        },
        getVoices() {
            this.$set('voices', speechSynthesis.getVoices())
            this.notifyVoices()
        },
        getVoice() {
            return this.voices[2]
        },
        notifyVoices() {
            this.$dispatch('tts-voices', this.voices)
        },
        notifyUtterance() {
            // Dispatched the utterence insance to the parent incase callbacks are wanted on events.
            this.$dispatch('tts-utterance', this.utterence)
        },
        notifyWord(index) {
            this.$dispatch('tts-word', this.words[index], index)
        },
        notifyformattedText() {
            var text = ""
            for (var i = 0 i < this.words.length i++) {
                text += '<span id="tts-' + i + '" class="tts-word">' + this.words[i] + '</span> '
            }
            this.$dispatch('tts-formatted-text', text)
        },
        notifyStart() {
            this.$dispatch('tts-start')
        },
        notifyPause() {
            this.$dispatch('tts-pause')
        },
        notifyStop() {
            this.$dispatch('tts-stop')
        }
    },
    data() {
        return {
            globalClasses: {},
            globalStyles: {},
            voices: [],
            displaySettings: {
                play: {
                    show: true,
                    text: 'Play',
                    icons: "",
                    displayAsIcon: false,
                    classes: "",
                    style: ""
                },
                stop: {
                    show: true,
                    text: 'Stop',
                    icons: "",
                    displayAsIcon: false,
                    classes: "",
                    style: ""
                },
                pause: {
                    show: true,
                    text: 'Pause',
                    icons: "",
                    displayAsIcon: false,
                    classes: "",
                    style: ""
                }
            },
            supported: true // if the browser supports Text to speech
        }
    }
}
</script>

<style scoped>
.icon {
    background: none;
    border: 0;
    outline-width: 0;
}
</style>
