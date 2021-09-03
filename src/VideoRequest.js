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
  constructor () {
    this.stop = false
    this.video = document.getElementById('video-view-element')
    this.canvas = document.getElementById('canvas-recorder')
    this.canvas.style.display = 'none'
    // create camera from canvas dimension
    const cameraRTT = new OrthographicCamera(this.canvas.width / -2, this.canvas.width / 2, this.canvas.height / 2, this.canvas.height / -2, -10000, 10000)
    cameraRTT.position.z = 500
    const sceneRTT = new Scene()
    // render what camera see and all elements in image
    const rtTexture = new WebGLRenderTarget(this.canvas.width, this.canvas.height, { minFilter: LinearFilter, magFilter: NearestFilter, format: RGBAFormat, type: UnsignedByteType })
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

    const plane = new PlaneBufferGeometry(this.canvas.width, this.canvas.height)
    const quad = new Mesh(plane, material)
    quad.position.z = -100
    sceneRTT.add(quad)

    const renderer = new WebGLRenderer()
    // console.log(window.devicePixelRatio) always 1
    renderer.setPixelRatio(window.devicePixelRatio)
    renderer.setSize(this.canvas.width, this.canvas.height)
    renderer.autoClear = false

    // console.log('renderer.domElement', renderer.domElement)
    // console.log('this.canvas', this.canvas)
    // document.getElementById('video-app').style.display = 'none'

    // create context from canvas to get video stream output
    this.ctx = this.canvas.getContext('2d')
    // create class variables
    this.renderer = renderer
    this.rtTexture = rtTexture
    this.sceneRTT = sceneRTT
    this.cameraRTT = cameraRTT
    // bind animate function to get every element accessible
    this.animate = this.animate.bind(this)
  }

  startVideoRecording () {
    this.stream = this.canvas.captureStream()
    this.recorder = new MediaRecorder(this.stream, { mimeType: 'video/webm' })
    let allChunks = []
    this.recorder.ondataavailable = function (e) { allChunks.push(e.data) }
    this.recorder.onstop = (e) => {
      const fullBlob = new Blob(allChunks, { 'type': 'video/webm' })
      const downloadUrl = window.URL.createObjectURL(fullBlob)
      console.log({fullBlob})
      console.log({downloadUrl})
      this.video.src = downloadUrl
      this.video.play()
    }
    this.recorder.start()
    requestAnimationFrame(this.animate)
  }

  stopRecording () {
    this.stop = true
    this.recorder.stop()
  }

  animate () {
    try {
      if (this.stop) return
      requestAnimationFrame(this.animate)
      // console.log(this.renderer)
      // console.log(this.sceneRTT)
      this.renderer.clear()
      this.renderer.render(this.sceneRTT, this.cameraRTT, this.rtTexture, true)

      // console.log(this.canvas.width, this.canvas.height)
      // console.log(this.canvas.width * this.canvas.height * 4)
      const read = new Uint8Array(this.canvas.width * this.canvas.height * 4)
      this.renderer.readRenderTargetPixels(this.rtTexture, 0, 0, this.canvas.width, this.canvas.height, read)

      // console.log(read, read.buffer)
      const buffer = new Uint8ClampedArray(read.buffer)
      // console.log(buffer)
      this.ctx.putImageData(new ImageData(buffer, this.canvas.width, this.canvas.height), 0, 0)
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
