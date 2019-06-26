# import { Meteor } from 'meteor/meteor';
#
# Template.camera.onRendered( function() {
#   var canvas, clearphoto, height, photo, startbutton, startup, streaming, takepicture, video, width;
#   width = 320;
#   height = 0;
#   streaming = false;
#   video = null;
#   canvas = null;
#   photo = null;
#   startbutton = null;
#   startup = function() {
#     video = document.getElementById('video');
#     canvas = document.getElementById('canvas');
#     photo = document.getElementById('photo');
#     startbutton = document.getElementById('startbutton');
#     navigator.mediaDevices.getUserMedia({
#       video: true,
#       audio: false
#     }).then(function(stream) {
#       video.srcObject = stream;
#       video.play();
#     })["catch"](function(err) {
#       console.log('An error occurred: ' + err);
#     });
#     video.addEventListener('canplay', (function(ev) {
#       if (!streaming) {
#         height = video.videoHeight / (video.videoWidth / width);
#         if (isNaN(height)) {
#           height = width / (4 / 3);
#         }
#         video.setAttribute('width', width);
#         video.setAttribute('height', height);
#         canvas.setAttribute('width', width);
#         canvas.setAttribute('height', height);
#         streaming = true;
#       }
#     }), false);
#     startbutton.addEventListener('click', (function(ev) {
#       takepicture();
#       ev.preventDefault();
#     }), false);
#     clearphoto();
#   };
#   clearphoto = function() {
#     var context, data;
#     context = canvas.getContext('2d');
#     context.fillStyle = '#AAA';
#     context.fillRect(0, 0, canvas.width, canvas.height);
#     data = canvas.toDataURL('image/png');
#     photo.setAttribute('src', data);
#   };
#   takepicture = function() {
#     var context, data, session;
#     context = canvas.getContext('2d');
#     if (width && height) {
#       canvas.width = width;
#       canvas.height = height;
#       context.drawImage(video, 0, 0, width, height);
#       data = canvas.toDataURL('image/png');
#       // console.log(Router.current().params.doc_id)
#       photo.setAttribute('src', data);
#       Meteor.call('set_kiosk_photo',Router.current().params.doc_id,data)
#     } else {
#       clearphoto();
#     }
#   };
#   window.addEventListener('load', startup, false);
# })();
