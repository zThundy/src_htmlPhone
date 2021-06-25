/* eslint-disable */
class VideoRTC {
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
    this.stream = document.getElementById("video-recorder-canvas").captureStream();
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
    // this.myPeerConnection.addStream(this.stream)
    this.stream = document.getElementById("video-recorder-canvas").captureStream()
    document.getElementById("target-stream").style.display = "none"
    this.stream.getTracks().forEach(track => {
      //console.log("addtrack to " + serverId);
      this.myPeerConnection.addTrack(track, streamElement)
    })

    this.myPeerConnection.onicecandidate = this.onicecandidate.bind(this)
    this.offer = await this.myPeerConnection.createOffer()
    this.myPeerConnection.setLocalDescription(this.offer)
    return btoa(JSON.stringify(this.offer))
  }

  async acceptCall (infoCall) {
    const offer = JSON.parse(atob(infoCall.rtcOffer))
    this.newConnection()
    this.initiator = false
    // this.myPeerConnection.addStream(this.stream)
  
    document.getElementById("video-recorder-canvas").style.display = "none"
    let video = document.getElementById("target-stream")
    video.style.display = "block"

    this.myPeerConnection.ontrack = (event) => {
      event.streams[0].getTracks().forEach(track => {
        video.srcObject.addTrack(track);
      })
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
}

/* eslint-disable */
(async function () {})()

export default VideoRTC
