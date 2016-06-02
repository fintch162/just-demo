$(".canned_response").change(function(event) {
  var canned_response_template = $(".canned_response option:selected").val();
  if(canned_response_template == ""){
    $("#canned_response_title").val("");
    $("#canned_response_description").val("");
    $("#canned_title").val("");
     $("#canned-delete").hide();
  }
  else {
    $("#canned_title").val(canned_response_template);
    $.ajax({
      url: '/manage/get_canned_tmp',
      type: 'POST',
      data: { choosenTemplate: canned_response_template },
      beforeSend: function() {
        $("#spinner").html('<img src="/assets/loading-spinner-default.gif" />');
      }
    })
    .done(function(data) {
      $("#spinner").html('');
      data = $.parseJSON(data)
      var id = data["id"]
      var title = data["title"]
      var description = data["description"]
      $("#canned_response_title").val(title);
      $("#canned_response_description").val(description);
      $('#canned-delete').replaceWith('<button type="button" id="canned-delete" class="btn red" data-toggle="modal" data-target=".canned-delete-modal">Delete</button>');
      console.log($('.canned-delete-modal .modal-body .row').html('<div class="row" style="text-align: center;"><a href="/manage/canned_responses/'+id+'" id="canned-delete" class = "btn red" data-method="delete"> Confirm </a> <button type="button" style="margin-left: 5%;" class="btn btn-default" data-dismiss="modal">Close</button></div>'));
    });

  }
});


 // <h3 >Confirm Delete</h3><%= @canned_response.inspect %>
 //          <a href="/manage/canned_responses/'+id+'" id="canned-delete" class = "btn red" data-method="delete" data-confirm ="Are you sure..??"> Delete </a>
 //          <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>