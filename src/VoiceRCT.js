const constraints = {
  video: false,
  audio: true
  // possibile implementazione della scelta del device da usare per la cattura
  // audio: (window.localStorage['tcm_gc_deviceId']) ? {deviceId : window.localStorage['tcm_gc_deviceId']} : true
}

/* eslint-disable */
class VoiceRTC {

  constructor (RTCConfig) {
    this.myPeerConnection = null
    this.candidates = []
    this.listener = {}
    this.myCandidates = []
    this.audio = new Audio()
    this.offer = null
    this.answer = null
    this.initiator = null
    this.RTCConfig = RTCConfig
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
    this.myPeerConnection.addStream(this.stream)
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
    // this.stream = await this.startModVoiceCall()
    this.myPeerConnection.onicecandidate = this.onicecandidate.bind(this)
    this.myPeerConnection.addStream(this.stream)
    this.offer = new RTCSessionDescription(offer)
    this.myPeerConnection.setRemoteDescription(this.offer)
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

  async startModVoiceCall () {
    let audioContext
    if (typeof AudioContext === 'function') {
      audioContext = new AudioContext()
    } else if (typeof webkitAudioContext === 'function') {
      // eslint-disable-line new-cap
      audioContext = new webkitAudioContext()
    }

    // Create a filter node.
    var filterNode = audioContext.createBiquadFilter()
    // See https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html#BiquadFilterNode-section
    filterNode.type = 'highpass'
    // Cutoff frequency. For highpass, audio is attenuated below this frequency.
    filterNode.frequency.value = 10000

    // Create a gain node to change audio volume.
    var gainNode = audioContext.createGain()
    // Default is 1 (no change). Less than 1 means audio is attenuated
    // and vice versa.
    gainNode.gain.value = 0.5

    return navigator.mediaDevices.getUserMedia(constraints, (stream) => {
      // Create an AudioNode from the stream.
      const mediaStreamSource = audioContext.createMediaStreamSource(stream)
      mediaStreamSource.connect(filterNode)
      filterNode.connect(gainNode)
      // Connect the gain node to the destination. For example, play the sound.
      gainNode.connect(audioContext.destination)
    })
  }

}

/* eslint-disable */
(async function () {
})()

export default VoiceRTC