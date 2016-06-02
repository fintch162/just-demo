$(document).on 'change', '#daily_backup_email', ->
  $.ajax(
    url: '/instructor/update_daily_backup_email_setting'
    type: 'GET'
    data: backup: @checked
  ).done((data)->
    console.log data
    return
  ).fail ->
    console.log("error");
    return
  return