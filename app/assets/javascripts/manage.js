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
//= require jquery.checknet-1.6.min
//= require manage/jquery.validate.min
//= require ./manage/kendo.web.min
//= require layout
//= require ./manage/data_table/default/default
//= require twitter/bootstrap
//= require ./manage/ready
//= require manage/login/jquery.uniform.min
//= require bootstrap-select
//= require manage/select2.min
//= require manage/jquery.multi-select
//= require manage/metronic
//= require manage/inbox
//= require manage/components-dropdowns
//= require manage/bootstrap-hover-dropdown.min
//= require manage/login/jquery.slimscroll.min
//= require manage/jquery.cookie.min
//= require manage/data_table/table-ajax
//= require manage/data_table/datatable
//= require manage/bootstrap-datepicker
//= require manage/bootstrap-timepicker
//= require manage/moment.min
//= require manage/daterangepicker
//= require manage/table-editable
//= require manage/components-pickers
//= require manage/bootstrap-datetimepicker.min
//= require jquery_nested_form
//= require manage/app
//= require manage/table-advanced
//= require components-pickers
//= require respond.min
//= require manage/createInvoiceValidate
//= require live_notifications
//= require manage/getInvoiceSms
//= require dashboardDaterange
//= require bootstrap-fileinput
//= require awards
//= require best_in_place
//= require jquery.sortable
//= require manage/jobs


// jQuery(document).ready(function() {
//   var last_invoice_id = "";
//   if($(".invoice_notifications").length > 0){
//     last_invoice_id = $("#header_notification_bar").find(".invoice_notify li").first().data("invoice_id");
//     console.log("last_invoice_id : " + last_invoice_id)
//     var source = new EventSource('/live_notifications?after='+last_invoice_id);
//     source.addEventListener('message', function(e) {
//       var data = JSON.parse(e.data);
//       var new_notify_cnt = data.length;
//       var old_notify_cnt = $("#header_notification_bar").find(".new_notify_cnt").text();
//       old_notify_cnt = $.trim(old_notify_cnt);
//       old_notify_cnt = parseInt(old_notify_cnt);
//       var new_cnt = parseInt(old_notify_cnt) + new_notify_cnt
//       for(var i = 0; i < data.length; i++){
//         var new_notifications ='<li class="invoice_notifications" data-invoice_id="'+data[i]["id"]+'"><a href="/manage/invoice?online_payments_invoice_id='+data[i]["invoice_id"]+'" target="_blank"><span class="label label-sm label-icon label-success"><i class="fa fa-plus"></i></span> '+data[i]["invoice_id"]+' <span class="time pull-right">6 days ago</span></a></li>';
//         $("#header_notification_bar").find(".invoice_notify li").first().before(new_notifications);
//         $("#header_notification_bar").find(".new_notify_cnt").text(new_cnt);
//       }
//       last_invoice_id = $("#header_notification_bar").find(".invoice_notify li").first().data("invoice_id");
//       console.log(last_invoice_id)
//     }, false);
//   }
// });

// var newYear = new Date(); 

$(document).ready(function(){
  // $.fn.checknet();
  // checknet.config.warnMsg = "No connection!!";
 
 
})