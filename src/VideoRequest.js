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

class VideoRequest {
  constructor (mainDiv, video) {
    this.video = video
    this.stop = false
    this.buffer = null
    this.read = null

    // get che canvas element present in the app.vue (main router)
    this.canvas = document.getElementById('canvas-recorder')
    this.canvas.style.display = 'none'
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

    const renderer = new WebGLRenderer()
    renderer.setPixelRatio(window.devicePixelRatio)
    // this will change the size of the camera:
    // smaller the camera lower the resolution
    // imagine a focal point in the center of the screen: if we create a camera with
    // 100 x 100 dimension, the camera will be big 100pixels by 100pixels and the camera
    // will be focused on the focal point at the center of the screen. Imagine as if it is
    // a 3 axes graph so.... yeah....
    renderer.setSize(window.innerWidth, window.innerHeight)
    renderer.autoClear = false

    // create context from canvas to get video stream output
    this.ctx = this.canvas.getContext('2d')
    // create class variables
    this.renderer = renderer
    this.rtTexture = rtTexture
    this.sceneRTT = sceneRTT
    this.cameraRTT = cameraRTT
    // bind animate function to get every element accessible
    this.animate = this.animate.bind(this)
    // bind this element to everything else
    // this.startVideoRecording = this.startVideoRecording.bind(this)
    // this.stopRecording = this.stopRecording.bind(this)
    this.startVideoLive(mainDiv)
    requestAnimationFrame(this.animate)
  }

  startVideoLive (mainDiv) {
    let liveCanvas = document.createElement('canvas')
    liveCanvas.style.cssText = `
      min-width: 100%;
      min-height: 89%;
      width: auto;
      height: auto;
      position: absolute;
      top: 55%;
      left: 108%;
      transform: translate(-50%, -50%);
    `
    mainDiv.appendChild(liveCanvas)
    this.live_ctx = liveCanvas.getContext('2d')
  }

  startVideoRecording () {
    this.stream = this.canvas.captureStream()
    this.recorder = new MediaRecorder(this.stream, { mimeType: 'video/webm' })
    let allChunks = []
    this.recorder.ondataavailable = function (e) { allChunks.push(e.data) }
    this.recorder.onstop = (e) => {
      const fullBlob = new Blob(allChunks, { 'type': 'video/webm' })
      const downloadUrl = window.URL.createObjectURL(fullBlob)
      // console.log({fullBlob})
      // console.log({downloadUrl})
      this.video.src = downloadUrl
      this.video.play()
    }
    this.recorder.start()
  }

  stopRecording () {
    this.stop = true
    this.recorder.stop()
  }

  animate () {
    try {
      if (this.stop) return
      requestAnimationFrame(this.animate)
      this.renderer.clear()
      this.renderer.render(this.sceneRTT, this.cameraRTT, this.rtTexture, true)

      // this.read = new Uint8Array(this.canvas.width * this.canvas.height * 4)
      // this.renderer.readRenderTargetPixels(this.rtTexture, 0, 0, this.canvas.width, this.canvas.height, this.read)
      this.read = new Uint8Array(window.innerWidth * window.innerHeight * 4)
      this.renderer.readRenderTargetPixels(this.rtTexture, 0, 0, window.innerWidth, window.innerHeight, this.read)

      // add buffer as class element for memory optimization
      this.buffer = new Uint8ClampedArray(this.read.buffer)
      this.ctx.putImageData(new ImageData(this.buffer, window.innerWidth, window.innerHeight), 0, 0)
      // add buffer to live canvas
      this.live_ctx.putImageData(new ImageData(this.buffer, window.innerWidth, window.innerHeight), 0, 0)
    } catch (e) { /* console.log(e) */ }
  }
}

// OLD CODE

// startVideoRecording () {
//   const canvas = document.getElementById('canvas1')
//   const ctx = canvas.getContext('2d')
//   const video = document.getElementById('canvas2')
//   video.play()
//   video.addEventListener('play', () => {
//     function step () {
//       ctx.drawImage(video, 0, 0, canvas.width, canvas.height)
//       requestAnimationFrame(step)
//     }
//     requestAnimationFrame(step)
//     const stream = canvas.captureStream()
//     const recorder = new MediaRecorder(stream, { mimeType: 'video/webm' })
//     let allChunks = []
//     recorder.ondataavailable = function (e) {
//       allChunks.push(e.data)
//     }
//     recorder.onstop = (e) => {
//       const fullBlob = new Blob(allChunks, { type: 'video/webm' })
//       const downloadUrl = window.URL.createObjectURL(fullBlob)
//       console.log({fullBlob})
//       console.log({downloadUrl})
//     }
//     recorder.start()
//     setTimeout(() => {
//       recorder.stop()
//     }, 5000)
//   })
//   // const stream = new MediaRecorder(_stream, { mimeType: 'video/webm' })
//   // console.log(stream)
//   // stream.ondataavailable = (e) => {
//   //   console.log('e.data checks')
//   //   if (e.data && e.data.size > 0) {
//   //     this.chunks.push(e.data)
//   //     console.log(this.chunks)
//   //     console.log('e.data')
//   //     console.log(e.data)
//   //   }
//   // }
//   // stream.onstop = (e) => {
//   //   console.log(e)
//   //   console.log('recording stopped')
//   //   const video = document.getElementById('canvas2')
//   //   ctx.drawImage(video, 0, 0, canvas.width, canvas.height)
//   //   const fullBlob = new Blob(this.chunks, { type: 'video/webm' })
//   //   const downloadUrl = window.URL.createObjectURL(fullBlob)
//   //   console.log(downloadUrl)
//   //   video.src = downloadUrl
//   // }
//   // stream.start()
//   // setTimeout(() => {
//   //   stream.stop()
//   // }, 5000)
// },
// startVideoRecording () {
//   const canvas = document.getElementById('canvas-recorder')
//   console.log(canvas)
//   const ctx = canvas.getContext('2d')
//   const video = document.querySelector('video')
//   console.log(canvas.width, canvas.height)
//   console.log(video.width, video.height)
//   // const read = new Uint8Array(canvas.width * canvas.height * 4)
//   // console.log(read)
//   // const d = new Uint8ClampedArray(read.buffer)
//   // console.log(d)
//   ctx.putImageData(new ImageData(d, canvas.width, canvas.height), 0, 0)
//   // On play event - draw the video in the canvas
//   // function step () {
//   //   ctx.drawImage(canvas, 0, 0, canvas.width, canvas.height)
//   //   requestAnimationFrame(step)
//   // }
//   // requestAnimationFrame(step)
//   // Init stream and recorder
//   const stream = canvas.captureStream()
//   const recorder = new MediaRecorder(stream, { mimeType: 'video/webm' })
//   // Get the blob data when is available
//   let allChunks = []
//   recorder.ondataavailable = function (e) {
//     allChunks.push(e.data)
//   }
//   recorder.onstop = (e) => {
//     const fullBlob = new Blob(allChunks, { 'type': 'video/webm' })
//     const downloadUrl = window.URL.createObjectURL(fullBlob)
//     console.log({fullBlob})
//     console.log({downloadUrl})
//     video.src = downloadUrl
//     video.play()
//   }
//   // Start to record
//   recorder.start()
//   // Stop the recorder after 5s and check the result
//   setTimeout(() => {
//     recorder.stop()
//   }, 5000)
// },

/* eslint-disable */
(async function () {})()

export default VideoRequest
