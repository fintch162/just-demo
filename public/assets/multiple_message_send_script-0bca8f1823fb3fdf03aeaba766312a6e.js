var SendSMSInGp = function () {
  var myTransaction1 = [];
  var myTransaction2 = [];


   var sendMessageScrip = function () { 
    $('#checkedAll').click(function(event) {
      if(this.checked) {
        $('.check_student').each(function() {
          this.checked = true;
          if($.inArray($(this).val(),myTransaction1)){
            myTransaction1.push($(this).val());
            $('.bulk_action_list').prop('disabled', false);
          }
        });
      } else {
        $('.check_student').each(function() {
          this.checked = false;
          if($.inArray($(this).val(),myTransaction1) != -1){
            myTransaction1.splice($.inArray($(this).val(),myTransaction1), 1);
            $('.bulk_action_list').prop('disabled', true);
          }
        });         
      }
      $('#send_message').val(myTransaction1);
    });

    $(".check_student").click(function() {
      if($(this).is(":checked")){
        var flag = 0;
        $(".check_student").each(function() {
          if(!this.checked){
            flag = 1;
            console.log($(this).val());
            $('.bulk_action_list').prop('disabled', false);
          }
        })              
        if(flag == 0) { $("#checkedAll").prop("checked", true); $('.bulk_action_list').prop('disabled', false);}
        if($.inArray($(this).val(),myTransaction1)){
          myTransaction1.push($(this).val());
        }
      }
      else {
        if($.inArray($(this).val(),myTransaction1) != -1){
          myTransaction1.splice($.inArray($(this).val(),myTransaction1), 1);
        }
        $("#checkedAll").prop("checked", false);
        if ($('.check_student:checked').length == 0){
          $('.bulk_action_list').prop('disabled', true);
        }
      }
      var id = $(this).attr('id');
      $('#send_message').val(myTransaction1);
      $(this).parents(".fields").remove();
    });
    
    $('.checkedAll_group').click(function(event) {
      var selected_group = $(this).attr('id');
        if(this.checked) {
          $('.'+selected_group).each(function() {
            this.checked = true;
            if($.inArray($(this).val(),myTransaction2)){
              myTransaction2.push($(this).val());
              console.log(myTransaction2);
              //$('.bulk_action_list').prop('disabled', false);
            }
          });
        } else {
          $('.'+selected_group).each(function() {
            this.checked = false;
            if($.inArray($(this).val(),myTransaction2) != -1){
              myTransaction2.splice($.inArray($(this).val(),myTransaction2), 1);
              console.log(myTransaction2);
              //$('.bulk_action_list').prop('disabled', true);
            }
          });         
        }
        $('#send_message').val(myTransaction2);
    });

    $(".check_student_group").click(function() {
      var selected_group = $(this).attr('id');
      console.log(selected_group);
      if($(this).is(":checked")){
        var flag = 0;
         $('.'+selected_group).each(function() {
         console.log("kkkkkkkkk");
         if(!this.checked){
            flag = 1;
            //console.log($(this).val());
            //$('.bulk_action_list').prop('disabled', false);
          }
        })              
        if(flag == 0) {
          $(this).closest('table').find(".checkedAll_group").prop("checked", true);
          //$(".checkedAll_group").prop("checked", true); 
          //$('.bulk_action_list').prop('disabled', false);
        }
        if($.inArray($(this).val(),myTransaction2)){
          myTransaction2.push($(this).val());
        }
      }
      else {
        if($.inArray($(this).val(),myTransaction2) != -1){
          myTransaction2.splice($.inArray($(this).val(),myTransaction2), 1);
        }
        $(".checkedAll_group").prop("checked", false);
        if ($('.check_student_group:checked').length == 0){
          //$('.bulk_action_list').prop('disabled', true);
        }
      }
      var id = $(this).attr('id');
      $('#send_message').val(myTransaction2);
      $(this).parents(".fields").remove();
    });

    $('#send_msg').click(function(){
      if ($('#send_message').val().length == 0 ){
        $('#error_msg').show();
        return false;  
      }
      else{
        $('#error_msg').hide(); 
        return true;
      }
    });

    $("#text_msg").keyup(function(event) {
      if(!$("#text_msg").val())
        $("#send_msg").attr('disabled','disabled');
      else
        $("#send_msg").removeAttr('disabled','disabled');
    });
    $("#send_msg").attr('disabled','disabled');
  };

  return {
    init: function () {
      sendMessageScrip();
    }
  };
}();
