function generateInvoiceSms(e) {
  getFromValues(e);
  var t = [];
  $.ajax({
    url: "/manage/message_templates/get_invoice_note?with_view_pa_link=invoice_pa",
    type: "get"
  }).done(function(e) {
    generateSmsPoll(e);
    textAreaAdjust1('instructor_message_template');
    textAreaAdjust1('customer_message_template');
  })
}

function invoicePaGenerateSMS() {
  for (var e = 0; e < template_identifier.length; e++) {
    if (template_identifier[e] == "< venue_name >") {
      if (venue_val == "Condo") template_value[e] = job_other_venue_val;
      else template_value[e] = venue_val
    }
    if (template_identifier[e] == "< instructor_name >") template_value[e] = $("#job_instructor_id option:selected").data("shortname");
    customer_message = solidReplace(customer_message, template_identifier[e], template_value[e])
  }
  $("#customer_message_template").val(templateDecoder(customer_message))
}

function generateSmsPoll(e) {
  first_detect = true;
  error_detect = false;
  warning_detect = false;
  error_fault = [];
  if (typeof e == "string") {
    customer_message = String(e);
    var t = [];
    for (var n = 0; n < template_identifier.length; n++) {
      if (e != "") {
        if (e.indexOf(template_identifier[n]) > 0) {
          if (template_identifier[n] != "< show_names >" && template_identifier[n] != "< lady_instructor >" && template_identifier[n] != "< free_goggles >" && template_identifier[n] != "< full_payment >") {
            t.push(template_identifier[n])
          }
        }
      }
    }
    isString = true
  } else {
    isString = false;
    customer_message = String(e[0]);
    instructor_message = String(e[1]);
    var t = [];
    for (var n = 0; n < template_identifier.length; n++) {
      if (e[1] != "") {
        if (e[1].indexOf(template_identifier[n]) > 0) {
          if (template_identifier[n] != "< show_names >" && template_identifier[n] != "< lady_instructor >" && template_identifier[n] != "< free_goggles >" && template_identifier[n] != "< full_payment >") {
            t.push(template_identifier[n])
          }
        }
      }
      if (e[0] != "") {
        if (e[0].indexOf(template_identifier[n]) > 0) {
          if (template_identifier[n] != "< show_names >" && template_identifier[n] != "< lady_instructor >" && template_identifier[n] != "< free_goggles >" && template_identifier[n] != "< full_payment >") {
            t.push(template_identifier[n])
          }
        }
      }
    }
  }
  t = $.unique(t);
  var r = [];
  var i = [];
  for (var s = 0; s < t.length; s++) {
    var o = t[s].substring(1, t[s].length - 1);
    o = $.trim(o);
    if (o == "id") i.push(current_job);
    else if (o == "student_count") i.push(student_count_val);
    else if (o == "list_students") i.push(list_students_val);
    else if (o == "fee_remainder") i.push(fee_remainder_val);
    else if (o == "lead_name") i.push(lead_name_val);
    else if (o == "lead_contact") i.push(lead_contact_val);
    else if (o == "instructor_contact") i.push(instructor_contact_val);
    else if (o == "venue_name") {
      if (venue_val == "Condo") {
        i.push(job_other_venue_val)
      } else {
        i.push(venue_val)
      }
    } else {
      i.push($("[data-name='" + o + "']").find("input,textarea,select").val())
    }
    r.push(o)
  }
  for (var s = 0; s < r.length; s++) {
    $("[data-name='" + r[s] + "']").find(".form-control").removeClass("error").addClass("success");
    if(r[s] == "instructor_contact")
      r[s] = "mobile"
    if (i[s] == null || i[s] == undefined || i[s] == "") {
      if (r[s] == "venue_name") r[s] = "s_job_other_venue";
      if ($("[data-name='" + r[s] + "']").is(":visible")) {
        if (first_detect == true) {
          $("html,body").animate({
            scrollTop: $("[data-name='" + r[s] + "']").offset().top - 46
          }, 500);
          first_detect = false
        }
        $("[data-name='" + r[s] + "']").find(".form-control").addClass("error");
        warning_detect = true
      } else {
        if (ispredefinedvarfilled(r[s]) == false) {
          error_fault.push(r[s]);
          error_detect = true
        }
      }
    }
  }
  if (warning_detect == true) return;
  if (error_detect == true) {
    var u = templateDecoder(customer_message);
    var a = [];
    if (isString == false) {
      var f = templateDecoder(instructor_message);
      var l = []
    }
    var c;
    var h = "";
    for (c = 0; c < error_fault.length; c++) {
      if (u.indexOf(error_fault[c]) != -1) a.push(error_fault[c])
    }
    if (isString == false) {
      for (c = 0; c < error_fault.length; c++) {
        if (f.indexOf(error_fault[c]) != -1) l.push(error_fault[c])
      }
    }
    if (a.length != 0 && l.length != 0) {
      h = "Customer Template  and Instructor Template"
    } else if (isString == false) {
      if (l.length != 0) h += "Instructor Template"
    } else if (a.length != 0) {
      h += "Customer Template"
    } else {
      generateSMSBtn();
      return
    } if (confirm("Sorry , Template has a syntax error in " + h + ".--Would you like to proceed?".replace(/--/g, "\n"))) {
      generateSMSBtn()
    }
  } else {
    generateSMSBtn()
  }
}

function checkEssential(e) {
  if ($.inArray(e, esential_arr) != -1) return true;
  return false
}

function generateSMSBtn() {
  for (var e = 0; e < template_identifier.length; e++) {
    
    if (template_identifier[e] == "< venue_name >") {
      if (venue_val == "Condo") template_value[e] = job_other_venue_val;
      else template_value[e] = venue_val
    }
    if (template_identifier[e] == "< instructor_name >") template_value[e] = $("#job_instructor_id option:selected").data("shortname");
    if (template_identifier[e] == "< instructor_contact >") template_value[e] = $(".caption").find("#inst_number").data("mobile");
    customer_message = solidReplace(customer_message, template_identifier[e], template_value[e]);
    
    if (isString == false) instructor_message = solidReplace(instructor_message, template_identifier[e], template_value[e])
  }
  $("#customer_message_template").val(templateDecoder(customer_message));
  if (isString == false) $("#instructor_message_template").val(templateDecoder(instructor_message))
}

function isMatched(e, t, n) {
  e = e.trim();
  t = t.trim();
  e = toLower(e);
  t = toLower(t);
  if (n == "==") {
    if (e == t) return true
  }
  if (n == "!=") {
    if (e != t) return true
  }
  if (n == ">") {
    if (e > t) return true
  }
  if (n == "<") {
    if (e < t) return true
  }
  if (n == "<=") {
    if (e <= t) return true
  }
  if (n == ">=") {
    if (e >= t) return true
  }
  return false
}

function getRes(e) {
  var t = ["==", "!=", ">", "<", ">=", "<="];
  var n = [];
  e = e.substr(1, e.length - 2);
  for (var r = 0; r < t.length; r++) {
    if (e.indexOf(t[r]) != -1) {
      n = e.split(t[r]);
      return isMatched(n[0], n[1], t[r])
    }
  }
  return "(" + e + ")"
}

function solidReplace(e, t, n) {
  if (e) {
    var r = e.split(t);
    return r.join(n)
  }
  return e
}

function getCount(e, t) {
  return e.split(t).length
}

function br2nl(e) {
  if (e) {
    return e.replace(/<br\s*\/?>/mg, "\n")
  }
  return e
}

function removenl(e) {
  if (e) {
    return e.replace(/(\r\n|\n|\r)/gm, "")
  }
  return e
}

function templateDecoder(e) {
  str = e;
  start = false;
  extrastr = "";
  newstring = "";
  conditions = [];
  str = solidReplace(str, '&#39;', "'"); 
  str = solidReplace(str, '&amp;', "&");
  str = solidReplace(str, "if(", "^(");
  str = solidReplace(str, "else{", "^^{");
  str = solidReplace(str, "&quot;", "");
  str = solidReplace(str, "&lt;", "<");
  str = solidReplace(str, "&gt;", ">");
  str = removenl(str);
  str = br2nl(str);
  for (var t = 0; t < str.length; t++) {
    char = String(str.charAt(t));
    if (char.indexOf("(") != -1) start = true;
    if (start == true) newstring += char;
    if (char.indexOf(")") != -1) {
      start = false;
      conditions.push(newstring);
      newstring = ""
    }
  }
  for (t = 0; t < conditions.length; t++) {
    var n = conditions[t];
    var r = getRes(n);
    str = solidReplace(str, n, r)
  }
  for (t = 0; str.lastIndexOf("^^{") != -1; t++) {
    var i = str.substr(0, str.lastIndexOf("^^{"));
    if (i.lastIndexOf("^true{") > i.lastIndexOf("^false{")) str = i + "^false{" + str.substr(i.length + 3);
    else str = i + "^true{" + str.substr(i.length + 3)
  }
  var s = "";
  var o = false;
  var u = 0;
  str = solidReplace(str, "^false", "`");
  for (var t = 0; t < str.length; t++) {
    char = String(str.charAt(t));
    if (char.indexOf("{") != -1) {
      if (o == true) {
        u += 1;
        s += "`"
      } else s += "{"
    } else if (char.indexOf("}") != -1) {
      if (o == true) {
        u -= 1;
        s += "`"
      } else s += "}"; if (u <= 0) o = false
    } else if (char.indexOf("`") != -1) {
      s += "`";
      o = true
    } else {
      if (o == true) s += "`";
      else s += char
    }
  }
  str = solidReplace(s, "`", "");
  nstr1 = solidReplace(str, "^true{", "");
  nstr1 = solidReplace(nstr1, "}", "");
  return nstr1
}
var isString = false


// Create Invoice : Send Freshbook Some custome Variables 

      function getQtyForInvoice() {
        var classT = $("#job_class_type option:selected").text();
        if(classT == "Group" || classT == "group")
          invoiceQty = $("#StudentCount").val();
        else
          invoiceQty = 1;
        return invoiceQty;
      }

      function getUnitCost() {
        var classT = $("#job_class_type option:selected").text();
        var totalStudent = $("#StudentCount").val();
        var perPax = $("#job_par_pax").val();
        var feeTotal = $("#job_fee_total").val();

        classT = classT.toLowerCase();
        if(classT == "group" && totalStudent > 1)
          unitCost = perPax
        
        if(classT == "group" && totalStudent == 1)
          unitCost = feeTotal

        if(classT == "private")
          unitCost = feeTotal

        return unitCost;
      }


      function getDescriptionInvoice() {
        var classT = $("#job_class_type option:selected").text();
        classT = classT.toLowerCase();

        var ageGroup = $("#job_age_group option:selected").text();
        ageGroup = ageGroup.toLowerCase();

        var feeTotal = $("#job_fee_total").val();

        var feeType = $("#job_fee_type_id option:selected").text();
        feeType = feeType.toLowerCase();

        var durationMins = $("#job_duration").val();
        var totalStudent = $("#StudentCount").val();
        var lessonCount = $("#job_lesson_count").val();

        if(classT == "group" && ageGroup == "kids") {
          if(feeType == "per month")
            descriptionDetail = "Kids group class \r Monthly fee";
        }

        if(classT == "group" && ageGroup == "adult") {
          if(feeType == "per course")  
            descriptionDetail = "Adult group class \r Weekly course for " + lessonCount + " consecutive weeks."
        }

        if(classT == "private") {
          if(feeType == "per course") {
            if(totalStudent > 1){
              descriptionDetail = "Private lessons ("+totalStudent+" students) \r"+lessonCount+" x "+durationMins+"min lessons";
            }
            else{
              descriptionDetail = "Private lessons ("+totalStudent+" student) \r"+lessonCount+" x "+durationMins+"min lessons";
            }
            $("#job_duration").css({'border-color': '#000'});
          }
        }
        return descriptionDetail;
      }

      function freeStarterKit() {
        var isGoogles = $('input:checkbox[name="job[free_goggles]"]').is(":checked");
        if(isGoogles == true)
          freeGoggles = "Free starter kit (premium set) \rOasis swimming goggles and cap";

        return freeGoggles;
      }


      function checkIsPrivateJob() {
        var durationMins = $("#job_duration").val();
        var classT = $("#job_class_type option:selected").text();
        classT = classT.toLowerCase();

        if(classT == "private") {
          if(durationMins == "") {
            $('html, body').animate({
              scrollTop: $("[data-name='duration']").offset().top - 46
            }, 1000);
            $("#job_duration").css({'border-color': 'red'});
            return false;
          }
        }
        return true;
      }