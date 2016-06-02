window.readyAdmin = ->
  $(".datepicker").kendoDatePicker
    format: "yyyy-mm-dd"

$(document).ready ->
  readyAdmin()