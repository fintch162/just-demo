//= require jquery
//= require jquery_ujs
//= require manage/jquery.validate.min
//= require manage/login/jquery-migrate-1.2.1.min
//= require manage/login/bootstrap-hover-dropdown.min
//= require manage/login/jquery.slimscroll.min
//= require manage/login/jquery.blockui.min
//= require manage/login/jquery.cokie.min
//= require manage/login/jquery.uniform.min
//= require manage/metronic
//= require layout
//= require manage/login/login
//= require live_notifications


jQuery(document).ready(function() {     
  Metronic.init(); // init metronic core components
  Layout.init(); // init current layout
  Login.init();
});