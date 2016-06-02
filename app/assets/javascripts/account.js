// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dropzone
//= require jquery.checknet-1.6.min
//= require manage/jquery.validate.min
//= require jquery.inview
//= require ./manage/kendo.web.min
//= require bootstrap2-typeahead.min
//= require ./manage/ready
//= require manage/jquery.multi-select
//= require manage/components-dropdowns
//= require manage/inbox
//= require account.dataTable
//= require manage/DT_bootstrap
//= require manage/jquery.dataTables.responsive
//= require bootstrap2-typeahead.min
//= require manage/bootstrap-hover-dropdown.min
//= require manage/login/jquery.slimscroll.min
//= require manage/jquery.cookie.min
//= require jquery.mixitup.min
//= require jquery.fancybox
//= require manage/bootstrap-datepicker
//= require manage/bootstrap-timepicker
//= require jquery_nested_form
//= require bootstrap-fileinput
//= require jquery.tagsinput
//= require typeahead.bundle.min
//= require bootstrap-select.min
//= require manage/select2.min
//= require manage/moment.min
//= require manage/daterangepicker
//= require manage/app
//= require jquery-migrate-1.2.1.min
//= require bootstrap.min
//= require jquery.fancybox.pack
//= require portfolio
//= require manage/instructor_student_table_editable
//= require components-form-tools
//= require fineuploader
//= require respond.min
//= require multiple_message_send_script
//= require multiple_message_send_instroctor_student_script
//= require manage/metronic
//= require layout
//= require best_in_place
//= require handsontable.full
//= require bootstrap-select
//= require jquery.mousewheel-3.0.6.pack
//= require croppic
// require main
//= require croppic_profile_pic
//= require jquery.mousewheel.min
//= require jquery.fileupload
//= require jquery.fancybox.pack
//= require video
//= require star-rating
//= require jquery.color-2.1.2.min


$(document).ready(function($) {
  if(location.hash == "#sms_setting") {
    $( "#smsSettings" ).trigger( "click" );
  }
});

$(document).ready(function(){
  // UNCOMMENT WHEN ASK TO CHECK INTERNET CONNECTED OR NOT
	  // $.fn.checknet();
	  // checknet.config.warnMsg = "No connection!!";
});
