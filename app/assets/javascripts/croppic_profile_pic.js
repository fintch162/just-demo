// $(document).ready(function(){
// 	var croppicHeaderOptions = {
// 			uploadUrl:'/instructor/student_identity/<%= @instructor_student.id %>',
// 			cropData:{
// 				"dummyData":1,
// 				"dummyData2":"asdas"
// 			},
// 			cropUrl:'img_crop_to_file.php',
// 			customUploadButtonId:'cropContainerHeaderButton',
// 			modal:true,
// 			imgEyecandyOpacity:0.4,
// 			processInline:true,
// 			loaderHtml:'<div class="loader bubblingG"><span id="bubblingG_1"></span><span id="bubblingG_2"></span><span id="bubblingG_3"></span></div> ',
// 			onBeforeImgUpload: function(){ console.log('onBeforeImgUpload') },
// 			onAfterImgUpload: function(){ console.log('onAfterImgUpload') },
// 			onImgDrag: function(){ console.log('onImgDrag') },
// 			onImgZoom: function(){ console.log('onImgZoom') },
// 			onBeforeImgCrop: function(){ console.log('onBeforeImgCrop') },
// 			onAfterImgCrop:function(){ console.log('onAfterImgCrop') },
// 			onError:function(errormessage){ console.log('onError:'+errormessage) }
// 	}	
// 	var croppic = new Croppic('croppic', croppicHeaderOptions);
// });
// 	