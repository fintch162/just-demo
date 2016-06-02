#= require active_admin/base

jQuery ->
  $("#group_class_lesson_count_input").hide()
  
  $(":radio[name=\"group_class[fee_type]\"]").change ->
    category = $(this).filter(":checked").val()
    if category is "per course"
      $("#group_class_lesson_count_input").show()
    else
      $("#group_class_lesson_count_input").hide()
    return
