import {
  OrthographicCamera,
  Scene,
  WebGLRenderTarget,
  LinearFilter,
  NearestFilter,
  RGBAFormat,
  UnsignedByteType,
  CfxTexture,
  ShaderMaterial,
  PlaneBufferGeometry,
  Mesh,
  WebGLRenderer
} from '@citizenfx/three'

const appWidth = 330
const appHeight = 710
// this help move the image on the x axis
// 200 is for selfie camera
// 100 is for normal camera
var xModifier = 0
// this help move the image on the y axis
var yModifier = 0

class VideoRequest {
  constructor (ip, port) {
    console.log('[MODULE] Video request class created successfully')
    this.stop = false
    this.buffer = null
    this.read = null
    this.ip = ip
    this.port = port
  }

  initRenderer (mainDiv, video) {
    // check if arguments in class are passed correctly
    if (!mainDiv || !video) {
      return console.error('[FATAL ERROR] Video request class cannot be initialized correctly')
    }
    console.log('[MODULE] Video request rendering function initialized')
    // create class variables
    this.mainDiv = mainDiv
    this.video = video
    // clear stop variable to start capturing again
    this.stop = false
    // set video width and height propriety to match the canvas
    if (this.video) this.video.width = appWidth
    if (this.video) this.video.height = appHeight
    // create camera from screen dimensions
    const cameraRTT = new OrthographicCamera(window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / -2, -10000, 10000)
    cameraRTT.position.z = 100
    const sceneRTT = new Scene()
    // render what camera see and all elements in image
    const rtTexture = new WebGLRenderTarget(window.innerWidth, window.innerHeight, { minFilter: LinearFilter, magFilter: NearestFilter, format: RGBAFormat, type: UnsignedByteType })
    // use fivem threejs to render all textoures and elements
    const gameTexture = new CfxTexture()
    gameTexture.needsUpdate = true
    // from here i don't know what this code does
    const material = new ShaderMaterial({
      uniforms: { 'tDiffuse': { value: gameTexture } },
      vertexShader: `
        varying vec2 vUv;
        void main() {
          vUv = vec2(uv.x, 1.0-uv.y); // fuck gl uv coords
          gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
        }
      `,
      fragmentShader: `
        varying vec2 vUv;
        uniform sampler2D tDiffuse;
        void main() {
          gl_FragColor = texture2D( tDiffuse, vUv );
        }
      `
    })

    this.material = material
    const plane = new PlaneBufferGeometry(window.innerWidth, window.innerHeight)
    const quad = new Mesh(plane, material)
    quad.position.z = -100
    sceneRTT.add(quad)

    const renderer = new WebGLRenderer({ preserveDrawingBuffer: true })
    renderer.setPixelRatio(window.devicePixelRatio)
    // this will change the size of the camera:
    // smaller the camera lower the resolution
    // imagine a focal point in the center of the screen: if we create a camera with
    // 100 x 100 dimension, the camera will be big 100pixels by 100pixels and the camera
    // will be focused on the focal point at the center of the screen. Imagine as if it is
    // a 3 axes graph so.... yeah....
    renderer.setSize(window.innerWidth, window.innerHeight)
    renderer.autoClear = false

    // create class variables
    this.renderer = renderer
    this.rtTexture = rtTexture
    this.sceneRTT = sceneRTT
    this.cameraRTT = cameraRTT
    // bind animate function to get every element accessible
    // bind this element to everything else
    this.animate = this.animate.bind(this)
    this.startVideoLive()
    requestAnimationFrame(this.animate)
  }

  clearRenderer () {
    console.log('[MODULE] Video request renderer cleared')
    this.stopCapture()
    this.stopRecording()
    this.mainDiv = null
    this.video = null
  }

  setXModifier (value) {
    let check = value
    if (check < 1) check *= -1
    if (check * 2 < window.innerWidth / 2) {
      xModifier = value
    }
  }

  getXModifier () {
    return xModifier
  }

  startVideoLive () {
    this.liveCanvas = document.createElement('canvas')
    this.liveCanvas.style.cssText = `
      display: block;
      width: 330px;
      height: 710px;
      top: 27px;
      position: absolute;
      z-index: 0;
    `
    // this.liveCanvas.width = window.innerWidth
    // this.liveCanvas.height = window.innerHeight
    if (this.liveCanvas) this.liveCanvas.width = appWidth
    if (this.liveCanvas) this.liveCanvas.height = appHeight
    if (this.mainDiv) this.mainDiv.appendChild(this.liveCanvas)
    this.liveCtx = this.liveCanvas.getContext('2d')
  }

  getVideoStream () {
    if (!this.stream) this.stream = this.liveCanvas.captureStream()
    return this.stream
  }

  // _startAudioRecorder () {
  //   navigator.mediaDevices.getUserMedia({ audio: true, video: false }).then(stream => {
  //     this.audioChunks = []
  //     this.isRecording = false
  //     this._mediaRecorder = new MediaRecorder(stream)
  //     this._mediaRecorder.ignoreMutedMedia = true
  //     this._mediaRecorder.addEventListener('start', () => { this.isRecording = true })
  //     this._mediaRecorder.addEventListener('dataavailable', (e) => {
  //       if (e.data && e.data.size > 0) {
  //         this.audioChunks.push(e.data)
  //       }
  //     }, true)
  //   })
  // }

  // _stopAudioRecorder () {
  //   return new Blob(this.audioChunks, { 'type': 'video/webm' })
  // }

  startVideoRecording (cb) {
    this.stream = this.liveCanvas.captureStream()
    this.recorder = new MediaRecorder(this.stream, { mimeType: 'video/webm' })
    let videoChunks = []
    this.recorder.ondataavailable = (e) => { videoChunks.push(e.data) }
    this.recorder.onstop = (e) => {
      // hide canvas
      this.liveCanvas.style.display = 'none'
      // create blob ready to be sent to the web server
      const fullBlob = new Blob(videoChunks, { 'type': 'video/webm' })
      const downloadUrl = window.URL.createObjectURL(fullBlob)
      this.video.src = downloadUrl
      this.video.play()
      this.video.onended = () => {
        // after video ends, show canvas again
        this.liveCanvas.style.display = 'block'
        // const audioBlob = this._stopAudioRecorder()
        // maybe show what to do with video?
        if (cb) cb(fullBlob)
      }
    }
    // this._startAudioRecorder()
    this.recorder.start()
    // this._mediaRecorder.start()
  }

  stopRecording () {
    if (this.recorder && this.recorder.state !== "inactive") this.recorder.stop()
  }

  stopCapture () {
    this.stop = true
  }

  async getVideoLinkFromServer (videoID = false) {
    if (!videoID) return console.error('[MODULE] Please provide a video id to make a correct fetch')
    return fetch(`http://${this.ip}:${this.port}/videoDownload?type=camera&key=${videoID}`, {
      method: 'GET'
    }).then(async resp => {
      if (resp.status === 404) return false
      var jsonResponse = await resp.json()
      return window.URL.createObjectURL(new Blob([Buffer.from(jsonResponse.blobDataBuffer, 'base64')]))
    }).catch(console.error)
  }

  async saveRecordedVideo (data = false) {
    if (!data) return console.error('[MODULE] Please fill in the required data argument')
    if (!data.blob) return console.error('[MODULE] Please provide a valid blob to upload')
    if (!data.id) return console.error('[MODULE] Please provide a valid id to the provided blob')
    if (!data.type) return console.error('[MODULE] Please provide a valid type for the uploader')
    const formData = new FormData()
    formData.append('video-file', data.blob)
    formData.append('filename', data.id)
    formData.append('type', data.type)
    return fetch(`http://${this.ip}:${this.port}/videoUpload`, {
      method: 'POST',
      body: formData
    }).then(resp => {
      if (resp.code === 500) return false
      return true
    }).catch(console.error)
  }

  animate () {
    try {
      if (this.stop) return
      requestAnimationFrame(this.animate)
      this.renderer.clear()
      this.renderer.render(this.sceneRTT, this.cameraRTT, this.rtTexture, true)
      this.read = new Uint8Array(window.innerWidth * window.innerHeight * 4)
      this.renderer.readRenderTargetPixels(this.rtTexture, 0, 0, window.innerWidth, window.innerHeight, this.read)
      // create buffer (clumped array) from renderer buffer
      // and save as class element for memory optimization
      this.buffer = new Uint8ClampedArray(this.read.buffer)
      // add buffer to live canvas
      // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/putImageData?retiredLocale=it
      // ctx.putImageData(imageData, dx, dy, dirtyX, dirtyY, dirtyWidth, dirtyHeight)
      this.liveCtx.putImageData(
        new ImageData(this.buffer, window.innerWidth, window.innerHeight),
        ((appHeight * -1) + xModifier),
        ((appWidth * -1) + yModifier),
        (appHeight - xModifier),
        (appWidth - yModifier),
        appWidth,
        appHeight
      )
    } catch (e) { console.log(e) }
  }
}

/* eslint-disable */
(async function () {})()

export default VideoRequest
