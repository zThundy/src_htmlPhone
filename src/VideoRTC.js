import RecordRTC from 'recordrtc'

const constraits = {
  video: true,
  audio: true
}

const options = {
  mimeType: 'video/webm;codecs=h264',
  type: 'video'
}

class VideoRTC {
  constructor (RTCConfig) {
    this.config = RTCConfig
  }

  async startRecording () {
    console.log('should be start recording (im in class VideoRTC)')
    let htmlObject = document.getElementById('video-recorder-canvas')
    console.log(htmlObject)
    /*
    var recorder = new CanvasRecorder(htmlObject, { disableLogs: true, useWhammyRecorder: true })
    recorder.record()
    recorder.stop(function (blob) {
      let video = URL.createObjectURL(blob)
      console.log(video)
    })
    */
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
}

/* eslint-disable */
(async function () {
})()

export default VideoRTC