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
//= require manage/jquery.validate.min
//= require best_in_place
//= require twitter/bootstrap
//= require manage/login/jquery.uniform.min
//= require manage/inbox
//= require manage/jquery.dataTables
//= require manage/DT_bootstrap
//= require manage/bootstrap-hover-dropdown.min
//= require index_page_js/jquery.slimscroll.min
//= require manage/bootstrap-datepicker
//= require manage/bootstrap-timepicker
//= require manage/metronic
//= require layout
//= require manage/table-editable
//= require manage/age_table_editable
//= require manage/venue_table_editable
//= require respond.min
//= require jquery.sortable
//= require manage/moment.min
//= require manage/script
//= require star-rating


function checkNumberOnly(e) {
  if(e.currentTarget.className.indexOf("bestinplaceInputDuration") != -1) {
    $(".bestinplaceInputDuration").css("border", "2px solid #0F7311");
    $(".bestinplaceInputDuration").attr("title", "Please enter numbers");
  }
  if(e.currentTarget.className.indexOf("bestinplaceInputLessionCnt") != -1) {
    $(".bestinplaceInputLessionCnt").css("border", "2px solid #0F7311");
    $(".bestinplaceInputLessionCnt").attr("title", "Please enter numbers");
  }

  if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 || (e.keyCode == 65 && e.ctrlKey === true) || (e.keyCode >= 35 && e.keyCode <= 40)) {
      return;
  }
  if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
    if(e.currentTarget.className.indexOf("bestinplaceInputDuration") != -1) {
      $(".bestinplaceInputDuration").css("border", "2px solid #ff0000");
      $(".bestinplaceInputDuration").attr("title", "Please enter numbers");
    }
    if(e.currentTarget.className.indexOf("bestinplaceInputLessionCnt") != -1) {
      $(".bestinplaceInputLessionCnt").css("border", "2px solid #ff0000");
      $(".bestinplaceInputLessionCnt").attr("title", "Please enter numbers");
    }
    e.preventDefault();
  }
}