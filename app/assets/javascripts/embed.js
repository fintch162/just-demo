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
//= require manage/jquery.multi-select
//= require layout
//= require manage/login/jquery.uniform.min
//= require manage/metronic
//= require manage/components-dropdowns
//= require jquery_nested_form
//= require bootstrap-datepicker
//= require manage/bootstrap-timepicker
//= require components-pickers
//= require respond.min
//= require embed/swimming-lesson-registration

$(document).ready(function(){
  // $.fn.checknet();
  // checknet.config.warnMsg = "No connection!!";
});

$(function() {
	var firstPageOptions = { direction: "right" };
  var secPageOptions = { direction: "right" };
	var effect = 'slide';
	var duration = 500;

   
  $('.bank_name').change(function(){
    if( $(this).is(":checked") ){
      var bank_detail = ($(this).val());
    }
    var bank_id = bank_detail.split("-")[0]
    var name = bank_detail.split("-")[1]
    var account_no = bank_detail.split("-")[2]
    
    $('.bank_transfer_btn').prop("disabled", false);
      $(".bank_transfer_btn").click(function () {
        $('#small').show();
        $( ".modal_bank_details" ).empty().append( "Bank: " + name + "</br>" +"Account No: " + account_no);
      });      
  });

  $(".confirm").click(function () {
    $('#small').hide();
    $('.bank_transfer_btn').prop("disabled", true);
  });
  
  $(".nextBtn").click(function () {
    $('.firstPage').toggle(effect, firstPageOptions, duration, function(){
      $('.secondPage').toggle(effect, secPageOptions, duration);
    });
  });
 	$(".previousBtn").click(function () {
    $('.secondPage').toggle(effect, secPageOptions, duration, function(){
      $('.firstPage').toggle(effect, firstPageOptions, duration);
    });
  });

  $(".try-again-button").click(function() {
    console.log("click");
    $(".payment_methods").show();
    $(".redDotError").hide();
    $(this).hide();
    $('.view-invoice').show();

  });

  var $div1 = $('#div1'), 
      $div2 = $('#div2'),
      currentDiv = 'div1',
      $button = $('button');

  $div2.hide();
  //$button.text('Toggle ' + currentDiv);

  $(".nextBtn").click(function () {
    $div1.toggle('slide', {direction: 'right'}, 'slow');
    $div2.toggle('slide', {direction: 'left'}, 'slow');
    
    currentDiv = (currentDiv === 'div1') ? 'div2' : 'div1';
    //$button.text('Toggle ' + currentDiv);
  });
  $(".previousBtn").click(function () {
    $div1.toggle('slide', {direction: 'right'}, 'slow');
    $div2.toggle('slide', {direction: 'left'}, 'slow');
    
    currentDiv = (currentDiv === 'div1') ? 'div2' : 'div1';
    //$button.text('Toggle ' + currentDiv);
  });

  var $div2 = $('#div2'), 
      $div3 = $('#div3'),
      currentDiv = 'div2',
      $button = $('button');

  $div3.hide();
  //$button.text('Toggle ' + currentDiv);

  $(".nextB").click(function () {
    var email_value = $('#custom_email').val();
    if(email_value == '')
    {
      event.preventDefault();
    }
    else{

    $div2.toggle('slide', {direction: 'right'}, 'slow');
    $div3.toggle('slide', {direction: 'left'}, 'slow');
    }
    
    currentDiv = (currentDiv === 'div2') ? 'div3' : 'div2';
    $('.bank_name').attr('checked', false)
    //$button.text('Toggle ' + currentDiv);
  });
  $(".previousB").click(function () {
    $div2.toggle('slide', {direction: 'right'}, 'slow');
    $div3.toggle('slide', {direction: 'left'}, 'slow');
    
    currentDiv = (currentDiv === 'div3') ? 'div3' : 'div2';

    $('.bank_name').attr('checked', false)
    //$button.text('Toggle ' + currentDiv);
  });

});
