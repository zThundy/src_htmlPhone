const constraints = {
  video: false,
  audio: true
  // possibile implementazione della scelta del device da usare per la cattura
  // audio: (window.localStorage['tcm_gc_deviceId']) ? {deviceId : window.localStorage['tcm_gc_deviceId']} : true
}

/* eslint-disable */
class VoiceRTC {

  constructor (RTCConfig, RTCFilters) {
    this.myPeerConnection = null
    this.candidates = []
    this.listener = {}
    this.myCandidates = []
    this.audio = new Audio()
    this.offer = null
    this.answer = null
    this.initiator = null
    this.audioContext = null
    this.RTCConfig = RTCConfig
    this.RTCFilters = RTCFilters
  }

  async init () {
    this.close()
    this.myPeerConnection = new RTCPeerConnection(this.RTCConfig)
    this.stream = await navigator.mediaDevices.getUserMedia(constraints)
    // this.stream = await this.startModVoiceCall()
  }

  newConnection () {
    this.close()
    this.candidates = []
    this.myCandidates = []
    this.listener = {}
    this.offer = null
    this.answer = null
    this.initiator = null
    this.myPeerConnection = new RTCPeerConnection(this.RTCConfig)
    this.myPeerConnection.onaddstream = this.onaddstream.bind(this)
  }

  close () {
    if (this.myPeerConnection !== null) {
      this.myPeerConnection.close()
    }
    this.myPeerConnection = null
  }

  async prepareCall () {
    await this.init()
    this.newConnection()
    this.initiator = true
    // controllo se da config i filtri sono attivi o no
    if (this.RTCConfig.enable) {
      // creazione dell'audiocontext per gli effetti
      this.audioContext = null
      this.audioContext = await this.getAudioContext()
      // qui mi prendo lo streamsource dalla stream promise per applicarci poi
      // i vari filtri
      const mediaStreamSource = this.audioContext.createMediaStreamSource(this.stream)
      // dopo aver preso il mediasource, mi creo le promise con i vari
      // filtri
      var biquadFilter = this.audioContext.createBiquadFilter()
      var gainNode = this.audioContext.createGain()
      var distortion = this.audioContext.createWaveShaper()
      // applico in ordine il filtro gain
      gainNode.gain.value = Number(this.RTCFilters.gain)
      mediaStreamSource.connect(gainNode)
      // poi il tipo di filtro biquadro
      biquadFilter.type = this.RTCFilters.biquadType
      biquadFilter.frequency.value = Number(this.RTCFilters.biquadFrequency)
      biquadFilter.detune.value = Number(this.RTCFilters.biquadDetune)
      biquadFilter.Q.value = Number(this.RTCFilters.biquadQuality)
      gainNode.connect(biquadFilter)
      // e infine applico la distorsione
      distortion.curve = makeDistortionCurve(this.RTCFilters.distortion)
      distortion.oversample = this.RTCFilters.oversample
      biquadFilter.connect(distortion)
      // Dopo aver applicato i filtri mi prendo la destinazione
      // e la collego al filtro completando la chain
      const mediaStreamDestination = this.audioContext.createMediaStreamDestination()
      distortion.connect(mediaStreamDestination)
      // infine collego l'intera chain di filtri allo stream
      // sull'rtc
      this.myPeerConnection.addStream(mediaStreamDestination.stream)
    } else {
      this.myPeerConnection.addStream(this.stream)
    }

    this.myPeerConnection.onicecandidate = this.onicecandidate.bind(this)
    this.offer = await this.myPeerConnection.createOffer()
    this.myPeerConnection.setLocalDescription(this.offer)
    return btoa(JSON.stringify(this.offer))
  }


  async acceptCall (infoCall) {
    const offer = JSON.parse(atob(infoCall.rtcOffer))
    this.newConnection()
    this.initiator = false
    this.stream = await navigator.mediaDevices.getUserMedia(constraints)
    // controllo se da config i filtri sono attivi o no
    if (this.RTCConfig.enable) {
      // creazione dell'audiocontext per gli effetti
      this.audioContext = null
      this.audioContext = await this.getAudioContext()
      // qui mi prendo lo streamsource dalla stream promise per applicarci poi
      // i vari filtri
      const mediaStreamSource = this.audioContext.createMediaStreamSource(this.stream)
      // dopo aver preso il mediasource, mi creo le promise con i vari
      // filtri
      var biquadFilter = this.audioContext.createBiquadFilter()
      var gainNode = this.audioContext.createGain()
      var distortion = this.audioContext.createWaveShaper()
      // applico in ordine il filtro gain
      gainNode.gain.value = Number(this.RTCFilters.gain)
      mediaStreamSource.connect(gainNode)
      // poi il tipo di filtro biquadro
      biquadFilter.type = this.RTCFilters.biquadType
      biquadFilter.frequency.value = Number(this.RTCFilters.biquadFrequency)
      biquadFilter.detune.value = Number(this.RTCFilters.biquadDetune)
      biquadFilter.Q.value = Number(this.RTCFilters.biquadQuality)
      gainNode.connect(biquadFilter)
      // e infine applico la distorsione
      distortion.curve = makeDistortionCurve(this.RTCFilters.distortion)
      distortion.oversample = this.RTCFilters.oversample
      biquadFilter.connect(distortion)
      // Dopo aver applicato i filtri mi prendo la destinazione
      // e la collego al filtro completando la chain
      const mediaStreamDestination = this.audioContext.createMediaStreamDestination()
      distortion.connect(mediaStreamDestination)

      this.myPeerConnection.addStream(mediaStreamDestination.stream)
    } else {
      this.myPeerConnection.addStream(this.stream)
    }

    // offerta icecandidates
    this.myPeerConnection.onicecandidate = this.onicecandidate.bind(this)
    this.offer = new RTCSessionDescription(offer)
    this.myPeerConnection.setRemoteDescription(this.offer)
    // creo la risposta dal server e aspetto la promise
    this.answer = await this.myPeerConnection.createAnswer()
    this.myPeerConnection.setLocalDescription(this.answer)
    return btoa(JSON.stringify(this.answer))
  }

  async onReceiveAnswer (answerData) {
    const answerObj = JSON.parse(atob(answerData))
    this.answer = new RTCSessionDescription(answerObj)
    this.myPeerConnection.setRemoteDescription(this.answer)
  }

  onicecandidate (event) {
    if (event.candidate !== undefined) {
      this.myCandidates.push(event.candidate)
      if (this.listener['onCandidate'] !== undefined) {
        const candidates = this.getAvailableCandidates()
        for (let func of this.listener['onCandidate']) {
          func(candidates)
        }
      }
    }
  }

  getAvailableCandidates() {
    const candidates = btoa(JSON.stringify(this.myCandidates))
    this.myCandidates = []
    return candidates
  }

  addIceCandidates (candidatesRaw) {
    if (this.myPeerConnection !== null) {
      const candidates = JSON.parse(atob(candidatesRaw))
      candidates.forEach((candidate) => {
        if (candidate !== null) {
          this.myPeerConnection.addIceCandidate(candidate)
        }
      })
    }
  }

  addEventListener (eventName, callBack) {
    if (eventName === 'onCandidate') {
      if (this.listener[eventName] === undefined) {
        this.listener[eventName] = []
      }
      this.listener[eventName].push(callBack)
      callBack(this.getAvailableCandidates())
    }
  }

  onaddstream(event) {
    this.audio.srcObject = event.stream
    this.audio.play()
  }

  getAudioContext() {
    var audioContext
    if (typeof AudioContext === 'function') {
      audioContext = new AudioContext()
    } else if (typeof webkitAudioContext === 'function') {
      // eslint-disable-line new-cap
      audioContext = new webkitAudioContext()
    }
    return audioContext
  }

  async startModVoiceCall () {
    // creazione dell'audiocontext per gli effetti
    this.audioContext = null
    if (typeof AudioContext === 'function') {
      this.audioContext = new AudioContext()
    } else if (typeof webkitAudioContext === 'function') {
      // eslint-disable-line new-cap
      this.audioContext = new webkitAudioContext()
    }

    // Create a filter node.
    // var filterNode = audioContext.createBiquadFilter()
    // See https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html#BiquadFilterNode-section
    // filterNode.type = 'lowpass'
    // Cutoff frequency. For highpass, audio is attenuated below this frequency.
    // filterNode.frequency.value = 10000

    // Create a gain node to change audio volume.
    // var gainNode = audioContext.createGain()
    // Default is 1 (no change). Less than 1 means audio is attenuated
    // and vice versa.
    // gainNode.gain.value = 0.5

    var distortion = this.audioContext.createWaveShaper()

    distortion.curve = makeDistortionCurve(400)
    distortion.oversample = '4x'

    return navigator.mediaDevices.getUserMedia(constraints, (stream) => {
      // Create an AudioNode from the stream.
      const mediaStreamSource = this.audioContext.createMediaStreamSource(stream)
      const mediaStreamDestination = this.audioContext.createMediaStreamDestination()

      mediaStreamSource.connect(distortion)
      // mediaStreamSource.connect(filterNode)
      // filterNode.connect(gainNode)
      distortion.connect(mediaStreamDestination)
      // Connect the gain node to the destination. For example, play the sound.
      // gainNode.connect(audioContext.destination)
    })
  }
}

function makeDistortionCurve(amount) {
  var k = typeof amount === 'number' ? amount : 50,
    n_samples = 44100,
    curve = new Float32Array(n_samples),
    deg = Math.PI / 180,
    i = 0,
    x;
  for ( ; i < n_samples; ++i ) {
    x = i * 2 / n_samples - 1;
    curve[i] = ( 3 + k ) * x * 20 * deg / ( Math.PI + k * Math.abs(x) );
  }
  return curve;
};

/* eslint-disable */
(async function () {
})()

export default VoiceRTC