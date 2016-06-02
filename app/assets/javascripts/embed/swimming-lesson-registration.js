$(function(){
  $('input[name="job[lead_class_type]"]').change(function(){
    var $radio = $(this);
    if($("#select_one_class_type").is(":visible"))
      $("#select_one_class_type").hide();
    $('label:has(input:radio:checked)').addClass('blue-madison');
    $('label:has(input:radio:not(:checked))').removeClass('blue-madison error');
    if (this.id == "Private") {
      $("#show_private").show('fast');
      // $("#preferred_day_private").show('fast');
      // $("#preferred_day_group").hide('fast');
      $("#venues_ids").hide('fast');
      $("#private_public_venue").show('fast');
    } else {
      $("#show_private" ).hide('fast');
      // $("#preferred_day_group").show('fast');
      // $("#preferred_day_private").hide('fast');
      $('input[name="job[private_lesson]"]').prop('checked', false);
      $('.other_venue').hide();
      $('#job_other_venue').val('');
      $('#venues_ids').show();
      $("#private_public_venue").hide('fast');
    }
  });
  $('#job_private_lesson').change(function() {
    var m = $(this).prop("checked");
    if(m == true){
      $("#private_public_venue").hide();
      $('.other_venue').show();
      $('#venues_ids').hide();
    }
    else{
      $("#private_public_venue").show();
      $('.other_venue').hide();
      $('#job_other_venue').val('');
      // $('#venues_ids').show();
    }
  });
});