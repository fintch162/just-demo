$ ->
  $(document).on 'click', '.applyGrpCls', ->
    selectedGroupClass = $(this).data('apply-gp')
    selectedJob = $("#job_h_id").val()
    $.ajax(
      url: '/manage/group_classes/apply-group-class-detail-to-job'
      type: 'POST'
      dataType: 'json'
      data: group_class: selectedGroupClass, job: selectedJob
    ).done((data)->
      copyGrpDetailsToJob(data)
      return
    ).fail(->
      return
    ).always ->
      return
    return

  copyGrpDetailsToJob = (data) ->
    classTime = moment.utc(data.class_time).format('h:mm A')
    studentCount = $("#StudentCount").val()
    FeeType = $("#job_fee_type_id").find('option[value="'+data.fee_type_id+'"]').text()
    
    $("#job_day_of_week").find('option').prop("selected", false)
    $("#job_day_of_week").find('option[value="'+data.day_of_week+'"]').prop("selected",true)

    $("#job_class_time").val(classTime)
    $("#job_duration").val(data.duration)

    $("#job_instructor_id").find('option').prop("selected", false)
    $("#job_instructor_id").find('option[value="'+data.instructor_id+'"]').prop("selected",true)
    $("#job_instructor_id").trigger('change')
    
    $("#job_fee_type_id").find('option').prop("selected", false)
    $("#job_fee_type_id").find('option[value="'+data.fee_type_id+'"]').prop("selected",true)

    if(FeeType == "per course")
      $("#job_fee_type_id").trigger('change')
      $("#job_lesson_count").val(data.lesson_count)
    if(FeeType == "per month")
      $("#job_fee_type_id").trigger('change')
      $("#job_lesson_count").val("")
    
    $("#job_referral").val("")

    if(studentCount > 1)
      $("[data-name='per_pax']").show()
      $("#job_par_pax").val(data.fee_total)
      $("#job_fee_total").val(data.fee_total * studentCount)
    else
      $("#job_fee_total").val(data.fee_total)

    $("#job_day_of_week").prop("disabled", true)
    $("#job_class_time").prop("disabled", true)
    $("#job_duration").prop("disabled", true)
    $("#job_fee_type_id").prop("disabled", true)
    $("#job_lesson_count").prop("disabled", true)
    $("#job_instructor_id").prop("disabled", true)
    $(".removeClassGp").removeAttr("disabled")

    $modal = $(".modal");
    $modal.modal('hide');

  $(document).on 'click', '.removeClassGp', ->
    selectedJob = $("#job_h_id").val()
    $this = $(this)
    $.ajax(
      url: '/manage/group_classes/remove-group-class-detail-from-job'
      type: 'POST'
      dataType: 'json'
      data: job: selectedJob
    ).done((data)->
      $this.attr("disabled", "disabled")
      $("#job_day_of_week").val("").prop("disabled", false)
      $("#job_class_time").val("").prop("disabled", false)
      $("#job_duration").val("").prop("disabled", false)
      $("#job_fee_type_id").val("").prop("disabled", false)
      $("#job_lesson_count").val("").prop("disabled", false)
      $("#job_instructor_id").val("").prop("disabled", false)
      $("#job_par_pax").val("")
      $("#job_fee_total").val("")
      $("#job_referral").val("")
      return
    ).fail(->
      return
    ).always ->
      return
    return
