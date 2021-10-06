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

import PhoneAPI from './PhoneAPI'

const created = Date.now()

class PictureRequest {
  constructor (config) {
    this.shot = false
    this.request = {
      encoding: config.encoding,
      quality: config.quality,
      targetField: config.field,
      targetURL: config.upload
    }
    if (!this.request.encoding) { console.log('[MODULE] [ERROR] Encoding field not given, using default'); this.request.encoding = 'png' }
    if (!this.request.quality) { console.log('[MODULE] [ERROR] Quality field not given, using default'); this.request.quality = 0.92 }
    if (!this.request.targetField) { console.log('[MODULE] [ERROR] Target field field not given, using default'); this.request.encoding = 'files[]' }
    if (!this.request.targetURL) { console.log('[MODULE] [ERROR] Target URL field not given, MODULE NOT INITIALIZED'); this.request = null; return }
    console.log('[MODULE] Picture request class created successfully')

    // create camera from screen dimensions
    const cameraRTT = new OrthographicCamera(window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / -2, -10000, 10000)
    cameraRTT.position.z = 100
    const sceneRTT = new Scene()
    // render what camera see and all elements in image
    const rtTexture = new WebGLRenderTarget(window.innerWidth, window.innerHeight, {
      minFilter: LinearFilter,
      magFilter: NearestFilter,
      format: RGBAFormat,
      type: UnsignedByteType
    })
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

    this.animate = this.animate.bind(this)
    requestAnimationFrame(this.animate)
  }

  animate () {
    console.log('animate', Date.now() - created)
    if (this.request === null) return
    console.log('animate')
    // tried on removing the recursive cause he just need 1 frame
    // requestAnimationFrame(this.animate)
    this.renderer.clear()
    this.renderer.render(this.sceneRTT, this.cameraRTT, this.rtTexture, true)
    if (!this.shot) {
      this.shot = true
      this.getPicture()
    }
  }

  getPicture () {
    console.log('getPicture', Date.now() - created)
    if (this.request === null) return
    // create canvas
    this.canvas = document.createElement('canvas')
    this.canvas.style.display = 'inline'
    this.canvas.width = window.innerWidth
    this.canvas.height = window.innerHeight
    console.log('canvas ok')
    // read the screenshot
    const read = new Uint8Array(window.innerWidth * window.innerHeight * 4)
    console.log('pixel rendering')
    this.renderer.readRenderTargetPixels(this.rtTexture, 0, 0, window.innerWidth, window.innerHeight, read)
    console.log('pixel rendered')
    // create a temporary this.canvas to compress the image
    // draw the image on the this.canvas
    console.log('read.buffer', read.buffer)
    const d = new Uint8ClampedArray(read.buffer)
    const ctx = this.canvas.getContext('2d')
    ctx.putImageData(new ImageData(d, window.innerWidth, window.innerHeight), 0, 0)
    console.log('got context :)')
    console.log(ctx)
    // encode the image
    let type = 'image/png'
    switch (this.request.encoding) {
      case 'jpg':
        type = 'image/jpeg'
        break
      case 'png':
        type = 'image/png'
        break
      case 'webp':
        type = 'image/webp'
        break
    }
    // actual encoding
    this.imageURL = this.canvas.toDataURL(type, this.request.quality)
    // upload the image somewhere
    fetch(this.request.targetURL, {
      method: 'POST',
      mode: 'cors',
      body: (this.request.targetField) ? this.getFormData() : JSON.stringify({ data: this.imageURL })
    })
    .then(response => response.text())
    .then(text => {
      var resp = ''
      if (text.length > 0) resp = JSON.parse(text)
      console.log('got response from ds deleting request')
      this.request = null
      console.log('returning response')
      PhoneAPI.ongetPicture(resp.attachments[0].url)
    })
  }

  getFormData () {
    const formData = new FormData()
    formData.append(this.request.targetField, this.dataURItoBlob(this.imageURL), `zth_gcphone.picture.${this.request.encoding}`)
    return formData
  }

  dataURItoBlob (dataURI) {
    const byteString = atob(dataURI.split(',')[1])
    const mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]
    const ab = new ArrayBuffer(byteString.length)
    const ia = new Uint8Array(ab)
    for (let i = 0; i < byteString.length; i++) ia[i] = byteString.charCodeAt(i)
    const blob = new Blob([ab], { type: mimeString })
    return blob
  }
}

/* eslint-disable */
(async function () {})()

export default PictureRequest
