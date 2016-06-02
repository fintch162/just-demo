function noteValidation(noteTemplate){
  var f_arr = [];
  for(var s=0; s<template_identifier.length; s++) {
    if(noteTemplate != ""){
      if(noteTemplate.indexOf(template_identifier[s]) > 0){
        if(template_identifier[s] != "< show_names >" && template_identifier[s] != "< lady_instructor >" && template_identifier[s] != "< free_goggles >"){
          f_arr.push(template_identifier[s]);
        }
      }
    }
  }
  f_arr = $.unique(f_arr);
  var ttty = [] 
  var value_v = [];
  for(var i=0; i<f_arr.length; i++){
    var result_template_identifier = f_arr[i].substring(1, f_arr[i].length-1);
    result_template_identifier = $.trim(result_template_identifier);

    if(result_template_identifier == "id")
      value_v.push(current_job);
    else if(result_template_identifier == "student_count")
      value_v.push(student_count_val);
    else if(result_template_identifier == "list_students")
      value_v.push(list_students_val);
    else if(result_template_identifier == "fee_remainder")
      value_v.push(fee_remainder_val);
    else if(result_template_identifier == "lead_name")
      value_v.push(lead_name_val);
    else if(result_template_identifier == "lead_contact")
      value_v.push(lead_contact_val);
    else if(result_template_identifier == "instructor_contact")
      value_v.push(instructor_contact_val);
    else if(result_template_identifier == "venue_name"){
      if(venue_val == "Condo"){
        value_v.push(job_other_venue_val);
      }
      else {
        value_v.push(venue_val);
      }
    }
    else
    {
      value_v.push($("[data-name='"+result_template_identifier+"']").find('input,textarea,select').val());
    }
    ttty.push(result_template_identifier)
  }

  var first_detect = true;
  var error_detect = false;
  var warning_detect = false;
  var error_fault = [];
  for(var i = 0; i<ttty.length; i++) {
    $("[data-name='"+ttty[i]+"']").find('.form-control').removeClass('error').addClass("success");

    if(value_v[i] == null || value_v[i] == undefined || value_v[i] == "")
    {
      if(ttty[i] == "venue_name"){
        if(venue_val == "Condo")
          ttty[i] = "s_job_other_venue"
      }
      if($("[data-name='"+ttty[i]+"']").is(":visible")){
        if(first_detect == true) {
          $('html,body').animate({
            scrollTop: $("[data-name='"+ttty[i]+"']").offset().top - 46
          },500);
          first_detect = false;
        }
        $("[data-name='"+ttty[i]+"']").find('.form-control').addClass("error");
        warning_detect=true;
      }
      else {
        if(ispredefinedvarfilled(ttty[i]) == false){
          error_fault.push(ttty[i])
          error_detect = true;
        }
      }
      $('#create_invoice').html("Create Invoice");
    }
  }

  if(warning_detect == true)
    return;
  if(error_detect == true){
    var custdecoder = templateDecoder(noteTemplate);
    var customerfaultfound = [];
    var indexi;
    var errinmsg = "";
    for(indexi=0;indexi<error_fault.length;indexi++)
    {
      if(custdecoder.indexOf(error_fault[indexi])!=-1)
        customerfaultfound.push(error_fault[indexi]);
    }
    if(customerfaultfound.length != 0) {
      errinmsg += "Invoice Note"
    }
    else {
      alert("There is an error with you template variables.("+error_fault+" "+")");
      return false
    }
  }
  else {
    
    for(var i=0; i<template_identifier.length; i++)
    {
      if(template_identifier[i] == "< venue_name >"){
        if(venue_val == "Condo")
          template_value[i] = job_other_venue_val
        else
          template_value[i] = venue_val
      }
      if(template_identifier[i] == '< instructor_name >')
        template_value[i] = $("#job_instructor_id option:selected").data("shortname");
      
      noteTemplate = solidReplace(noteTemplate, template_identifier[i], template_value[i]);
    }
    return noteTemplate
  }
}