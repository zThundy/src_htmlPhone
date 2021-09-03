import {
  OrthographicCamera,
  Scene,
  WebGLRenderTarget,
  LinearFilter,
  NearestFilter,
  RGBAFormat,
  UnsignedByteType,
  // CfxTexture,
  ShaderMaterial,
  PlaneBufferGeometry,
  Mesh,
  WebGLRenderer
} from 'three'

class VideoRequest {
  constructor () {
    this.stop = false
    this.video = document.getElementById('video-view-element')
    this.canvas = document.getElementById('canvas-recorder')

    const cameraRTT = new OrthographicCamera(this.canvas.width / -2, this.canvas.width / 2, this.canvas.heigth / 2, this.canvas.heigth / -2, -10000, 10000)
    cameraRTT.position.z = 100

    const sceneRTT = new Scene()

    const rtTexture = new WebGLRenderTarget(this.canvas.width, this.canvas.heigth, { minFilter: LinearFilter, magFilter: NearestFilter, format: RGBAFormat, type: UnsignedByteType })
    // const gameTexture = new CfxTexture()
    // gameTexture.needsUpdate = true

    const material = new ShaderMaterial({
      // uniforms: { 'tDiffuse': { value: gameTexture } },
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

    const plane = new PlaneBufferGeometry(this.canvas.width, this.canvas.heigth)
    const quad = new Mesh(plane, material)
    quad.position.z = -100
    sceneRTT.add(quad)

    const renderer = new WebGLRenderer()
    renderer.setPixelRatio(window.devicePixelRatio)
    renderer.setSize(this.canvas.width, this.canvas.heigth)
    renderer.autoClear = false

    document.getElementById('video-app').appendChild(renderer.domElement)
    document.getElementById('video-app').style.display = 'none'

    this.renderer = renderer
    this.rtTexture = rtTexture
    this.sceneRTT = sceneRTT
    this.cameraRTT = cameraRTT

    this.animate = this.animate.bind(this)

    this.ctx = this.canvas.getContext('2d')

    this.stream = this.canvas.captureStream()
    this.recorder = new MediaRecorder(this.stream, { mimeType: 'video/webm' })

    let allChunks = []
    this.recorder.ondataavailable = function (e) {
      allChunks.push(e.data)
    }

    this.recorder.onstop = (e) => {
      const fullBlob = new Blob(allChunks, { 'type': 'video/webm' })
      const downloadUrl = window.URL.createObjectURL(fullBlob)
      console.log({fullBlob})
      console.log({downloadUrl})
      this.video.src = downloadUrl
      this.video.play()
    }
    // Start to record
    this.recorder.start()

    requestAnimationFrame(this.animate)
  }

  animate () {
    if (this.stop) return
    requestAnimationFrame(this.animate)
    this.renderer.clear()
    this.renderer.render(this.sceneRTT, this.cameraRTT, this.rtTexture, true)

    const read = new Uint8Array(this.canvas.width * this.canvas.heigth * 4)
    this.renderer.readRenderTargetPixels(this.rtTexture, 0, 0, this.canvas.width, this.canvas.heigth, read)

    const buffer = new Uint8ClampedArray(read.buffer)
    this.ctx.putImageData(new ImageData(buffer, this.canvas.width, this.canvas.heigth), 0, 0)
  }

  stopRecording () {
    this.stop = true
    this.recorder.stop()
  }
}

/* eslint-disable */
(async function () {})()

export default VideoRequest
