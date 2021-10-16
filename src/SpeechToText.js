/* eslint-disable */
class SpeechRecon {
  constructor (language = 'it-IT') {
    this.recon = this.getSpeechRecognition()
    this.recon.lang = language
    this.recon.continuous = true
    this.finalTranscript = ''
    this.interimTranscript = ''

    console.log('[MODULE] Speech to text class created successfully')

    this.recon.onresult = event => {
      console.log('got event lol')
      // concatenate all the transcribed pieces together (SpeechRecognitionResult)
      for (let i = event.resultIndex; i < event.results.length; i += 1) {
        const transcriptionPiece = event.results[i][0].transcript;
        // check for a finalised transciption in the cloud
        if (event.results[i].isFinal) {
          this.finalTranscript += transcriptionPiece;
          console.log('finalTranscript', this.finalTranscript)
          this.finalTranscript = '';
        } else if (this.recognition.interimResults) {
          this.interimTranscript += transcriptionPiece;
          console.log('interimTranscript', this.interimTranscript)
        }
      }
    }

    this.recon.onend = () => {
      console.log('finished capturing')
      this.recon.start()
    };
  }

  getApproxText () {
    return this.recon.interimResults()
  }

  startRecognition () {
    console.log('started capturing')
    this.recon.start()
  }

  stopRecognition () {
    this.recon.stop()
  }

  getSpeechRecognition () {
    if (typeof SpeechRecognition === 'function') {
      return new SpeechRecognition()
    } else if (typeof webkitSpeechRecognition === 'function') {
      return new webkitSpeechRecognition()
    }
  }
}

/* eslint-disable */
(async function () {})()

export default SpeechRecon