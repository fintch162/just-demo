# window.groupClassModel = kendo.observable
#   group_classes: new kendo.data.DataSource(
#     new kendoSchemeBuilder(
#       rootNode: 'group_classes',
#       url: '/manage/group_classes'
#       model:
#         id: "id"
#         fields:
#           actions: editable: false
#           day: editable: false
#           time: editable: false
#           instructor: editable: false
#           level: editable: false
#           class_type: editable: false
#           age_group: editable: false
#           venue: editable: false

#       dataMapper: (data)->
#         group_class:
#           day: data.day
#           time: data.time
#           instructor: data.instructor
#           duration: data.duration
#           fee: data.fee
#           level: data.level
#           class_type_id: data.class_type_id
#           age_group_id: data.age_group_id
#           venue_id: data.venue_id
#           lesson_count: data.lesson_count
#           remarks: data.remarks
#     ).scheme
#   )
jQuery ->
  day = $("#day").find("option:selected").text()
  venue = $("#venue").find("option:selected").text()
  instructor = $("#instructor").find("option:selected").text()
  age_group = $("#age_group").find("option:selected").text()
  $("#search_gp").addClass "disabled"  if day is "Any" and venue is "Any" and instructor is "Any" and age_group is "Any"

  $("#day").change ->
    day = $("#day").find("option:selected").text()
    venue = $("#venue").find("option:selected").text()
    instructor = $("#instructor").find("option:selected").text()
    age_group = $("#age_group").find("option:selected").text()
    unless day is "Any"
      $("#search_gp").removeClass "disabled"
    else if day is "Any"
      $("#search_gp").removeClass "disabled"  if venue isnt "Any" or instructor isnt "Any" or age_group isnt "Any"
      $("#search_gp").addClass "disabled"  if day is "Any" and venue is "Any" and instructor is "Any" and age_group is "Any"
    return

  $("#venue").change ->
    day = $("#day").find("option:selected").text()
    venue = $("#venue").find("option:selected").text()
    instructor = $("#instructor").find("option:selected").text()
    age_group = $("#age_group").find("option:selected").text()
    unless venue is "Any"
      $("#search_gp").removeClass "disabled"
    else if venue is "Any"
      $("#search_gp").removeClass "disabled"  if day isnt "Any" or venue is "Any" or instructor isnt "Any" or age_group isnt "Any"
      $("#search_gp").addClass "disabled"  if day is "Any" and venue is "Any" and instructor is "Any" and age_group is "Any"
    return

  $("#instructor").change ->
    day = $("#day").find("option:selected").text()
    venue = $("#venue").find("option:selected").text()
    instructor = $("#instructor").find("option:selected").text()
    age_group = $("#age_group").find("option:selected").text()
    unless instructor is "Any"
      $("#search_gp").removeClass "disabled"
    else if instructor is "Any"
      $("#search_gp").removeClass "disabled"  if day isnt "Any" or venue isnt "Any" or instructor is "Any" or age_group isnt "Any"
      $("#search_gp").addClass "disabled"  if day is "Any" and venue is "Any" and instructor is "Any" and age_group is "Any"
    return

  $("#age_group").change ->
    day = $("#day").find("option:selected").text()
    venue = $("#venue").find("option:selected").text()
    instructor = $("#instructor").find("option:selected").text()
    age_group = $("#age_group").find("option:selected").text()
    unless age_group is "Any"
      $("#search_gp").removeClass "disabled"
    else if age_group is "Any"
      $("#search_gp").removeClass "disabled"  if day isnt "Any" or venue isnt "Any" or instructor isnt "Any" or age_group is "Any"
      $("#search_gp").addClass "disabled"  if day is "Any" and venue is "Any" and instructor is "Any" and age_group is "Any"
    return
