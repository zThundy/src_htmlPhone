import RecordRTC from 'recordrtc'

const constraits = {
  audio: true
}

const options = {
  // recorderType: RecordRTC.MediaStreamRecorder,
  // mimeType: 'video/video/webmcodecs=h264',
  // ignoreMutedMedia: true,
  // previewStream (stream) {
  //   console.log('previewstream in options')
  //   console.log(stream)
  //   console.log('-----------------------')
  // }
  type: 'video'
  // mimeType: 'video/webm;codecs=vp8,opus'
}

class VideoRTC {
  constructor (RTCConfig) {
    this.config = RTCConfig
    this.recorder = null
    this.audioStream = null
    this.canvasStream = null
  }

  async clearRecording () {
    this.recorder = null
  }

  async stopRecordingManually () {
    if (this.recorder) {
      this.recorder.stopRecording()
    }
  }

  async startRecording () {
    navigator.mediaDevices.getUserMedia(constraits).then(audioStream => {
      var canvas = document.getElementById('video-recorder-canvas')
      this.canvasStream = canvas.captureStream()

      this.audioStream = audioStream

      var finalStream = new MediaStream()
      // capture the audio element from the getusermedia function
      this.audioStream.getTracks('audio').forEach(track => {
        console.log('found audio track and added to mediastream')
        console.log(track)
        finalStream.addTrack(track)
      })
      // capture the video element from the canvass
      this.canvasStream.getTracks('video').forEach(track => {
        console.log('found video track and added to mediastream')
        console.log(track)
        finalStream.addTrack(track)
      })
      console.log(finalStream)
      console.log('finalStream.getAudioTracks()')
      console.log(finalStream.getAudioTracks())
      this.recorder = RecordRTC(finalStream, options)
      this.recorder.startRecording()
      console.log(this.recorder)
      Object.keys(this.recorder)

      // while (this.recorder.state === 'stopped') {
      //   console.log('recording is stopped')
      // }

      setTimeout(() => {
        this.recorder.stopRecording(() => {
          // var timestamp = (new Date()).valueOf()
          // let fileName = timestamp + '.webm'
          // console.log(this.recorder.getBlob())
          // console.log(fileName)
          // let invokesavelog = this.invokeSaveAsDialog(this.recorder.getBlob(), fileName)
          // console.log(invokesavelog)
          // var blob = recorder.getBlob()
          // var file = new File([blob], fileName, {
          //     type: 'video/webm'
          // })
          this.audioStream.stop()
          this.canvasStream.stop()

          var blob = this.recorder.getBlob()
          var video = document.createElement('video')
          video.src = URL.createObjectURL(blob)
          console.log('video.src')
          console.log(video.src)
          video.setAttribute('style', 'height: 50%; position: absolute; top:0; left:0; z-index:9999; width:auto, min-width: 100px;')
          document.body.appendChild(video)
          video.controls = true
          video.play()
        })
      }, 5000)
    })

    // console.log('called startRecording from class VideoRTC')
    // navigator.mediaDevices.getUserMedia(constraits).then(microphone => {
    //   console.log(microphone)
    //   console.log('document.getElementById(canvaselements))')
    //   console.log(document.getElementById('video-recorder-canvas'))
    //   var canvasStream = document.getElementById('video-recorder-canvas').captureStream()
    //   console.log('canvasStream')
    //   console.log(canvasStream)
    //   canvasStream.onaddtrack = function () {
    //     console.log('new track added to canvas')
    //   }
    //   microphone.getAudioTracks().forEach(audioTrack => {
    //     console.log('added audio track to stream')
    //     console.log(audioTrack)
    //     canvasStream.addTrack(audioTrack)
    //   })
    //   console.log('canvasStream2')
    //   console.log(canvasStream)
    //   // now you can record "canvasStream" which include "microphone" tracks as well
    //   this.recorder = RecordRTC(canvasStream, options)
    //   this.recorder.startRecording()
    // })
  }

  invokeSaveAsDialog (file, fileName) {
    if (!file) {
      console.err('Blob object is required.')
    }
    if (!file.type) {
      try {
        file.type = 'video/webm'
      } catch (e) {}
    }
    var fileExtension = (file.type || 'video/webm').split('/')[1]
    if (fileExtension.indexOf('') !== -1) {
      // extended mimetype, e.g. 'video/webmcodecs=vp8,opus'
      fileExtension = fileExtension.split('')[0]
    }
    if (fileName && fileName.indexOf('.') !== -1) {
      var splitted = fileName.split('.')
      fileName = splitted[0]
      fileExtension = splitted[1]
    }
    let filename = fileName || (Math.round(Math.random() * 9999999999) + 888888888)
    var fileFullName = filename + '.' + fileExtension
    if (typeof navigator.msSaveOrOpenBlob !== 'undefined') {
      return navigator.msSaveOrOpenBlob(file, fileFullName)
    } else if (typeof navigator.msSaveBlob !== 'undefined') {
      return navigator.msSaveBlob(file, fileFullName)
    }
    var hyperlink = document.createElement('a')
    hyperlink.href = URL.createObjectURL(file)
    hyperlink.download = fileFullName
    hyperlink.style = 'display:noneopacity:0color:transparent'
    let body = document.body || document.documentElement
    body.appendChild(hyperlink)
    if (typeof hyperlink.click === 'function') {
      hyperlink.click()
    } else {
      hyperlink.target = '_blank'
      hyperlink.dispatchEvent(new MouseEvent('click', {
        view: window,
        bubbles: true,
        cancelable: true
      }))
    }
    URL.revokeObjectURL(hyperlink.href)
  }

  /*
  async startRecording () {
    console.log('should be start recording (im in class VideoRTC)')
    let htmlObject = document.getElementById('video-recorder-canvas')
    console.log(htmlObject)
    // var recorder = new CanvasRecorder(htmlObject, { disableLogs: true, useWhammyRecorder: true })
    // recorder.record()
    // recorder.stop(function (blob) {
    //   let video = URL.createObjectURL(blob)
    //   console.log(video)
    // })
    // navigator.mediaDevices.getDisplayMedia(constraits).then(stream => {
    navigator.mediaDevices.getUserMedia(constraits).then(async function (stream) {
      // options.video = RecordRTC.CanvasRecorder(htmlObject, {})
      options.previewStream = function (stream) {
        console.log(stream)
      }
      let recorder = RecordRTC(stream, options)
      console.log(recorder)
      recorder.startRecording()

      setTimeout(() => {
        recorder.stopRecording(function () {
          let blob = recorder.getBlob()
          console.log(blob)
          console.log(recorder.toURL())
          let blobUrl = recorder.save('video.webm')
          console.log(blobUrl)
          console.log(recorder.getDataURL(blobUrl))
        })
      }, 5000)
    })
  }
  */
}

/* eslint-disable */
(async function () {
})()

export default VideoRTC