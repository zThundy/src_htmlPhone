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

  // this function will initialazie a rtc peer to peer connection
  // using the server specified in the config.json and save the media
  // stream inside a class variable
  async init (stream) {
    this.close()
    this.myPeerConnection = new RTCPeerConnection(this.RTCConfig)
    if (!stream) {
      this.stream = await navigator.mediaDevices.getUserMedia(constraints)
    } else {
      this.stream = stream
    }
  }

  // this function will create a new connection without distinguishing if
  // you are the initiator or not
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

  // if a connection is opened, this function will
  // close it at any point
  close () {
    if (this.myPeerConnection !== null) this.myPeerConnection.close()
    this.myPeerConnection = null
  }

  // function called from the initiator of the rtc call
  // Need to add the stream element and create and RTC connection (see this.init())
  async prepareCall (stream = false) {
    await this.init(stream)
    this.newConnection()
    this.initiator = true
    // controllo se da config i filtri sono attivi o no
    if (this.RTCConfig.enable && !stream) {
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

  // function called from second client that accepts the receiving call
  // Need to add stream (cause the second client does not have it)
  // Need to add the remote stream to an html obj
  async acceptCall (infoCall, stream = false) {
    const offer = JSON.parse(atob(infoCall.rtcOffer))
    this.newConnection()
    this.initiator = false
    if (!stream) {
      this.stream = await navigator.mediaDevices.getUserMedia(constraints)
    } else {
      this.stream = stream
    }
    // controllo se da config i filtri sono attivi o no
    if (this.RTCConfig.enable && !stream) {
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

  getAvailableCandidates () {
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

  onaddstream (event) {
    this.audio.srcObject = event.stream
    this.audio.play()
  }

  getAudioContext() {
    if (typeof AudioContext === 'function') {
      return new AudioContext()
    } else if (typeof webkitAudioContext === 'function') {
      return new webkitAudioContext()
    }
  }
}

// taken from mozilla site
function makeDistortionCurve(amount) {
  var k = typeof amount === 'number' ? amount : 50,
    n_samples = 44100,
    curve = new Float32Array(n_samples),
    deg = Math.PI / 180,
    i = 0,
    x;
  for ( ; i < n_samples; ++i ) {
    x = i * 2 / n_samples - 1;
    curve[i] = (3 + k) * x * 20 * deg / (Math.PI + k * Math.abs(x));
  }
  return curve
}

/* eslint-disable */
(async function () {})()

export default VoiceRTC