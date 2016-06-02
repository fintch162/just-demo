// var f_date;
// var job_h_id = $("#job_h_id").val();
// var messg_b = "";

// // START --> From job show page send messages for cutomer and instructor
//     $("#instructor_send_message").click(function(){
//       var instructor = $("#job_instructor_id").find('option:selected').text();
//       if(instructor == "Please Select"){
//         alert("Please select instructor to send message!")
//       }
//       else{
//         var message_body = $("#instructor_message_template").val();
//         if(message_body != "") {
//           instructor = $.trim(instructor.substring(0, instructor.indexOf('-')));
//           $.ajax({
//             url: '/manage/get_instructor',
//             type: 'get',
//             data: { instructor: instructor },
//           })
//           .done(function(data) {
//             var inst_to_number = data;
//             $.ajax({
//               url: '/manage/job_message_send',
//               type: 'get',
//               data: { instructor: instructor , message_body: message_body, job_id: job_h_id, messg_b: messg_b },
//               beforeSend : function(){
//                 $("#inst_message_status").html("Sending SMS...").show();
//                 set_tr_conversation = '<li class="out sending"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message" style="background-color: pink;"><span class="arrow"></span>  <a class="name" href="#">'+ inst_to_number +' </a> <span class="datetime"> sending...</span><span class="body replace_str">'+ $("#instructor_message_template").val(); +'</span></div></li>';
//                 $("#instructor_conversation").find('li').first().before(set_tr_conversation);
//                 $('.inst_scroller').animate({scrollTop: $('.inst_scroller')[0].scrollHeight}, 'slow');
//               }
//               })
//               .fail(function(data) {
//                 if(data.responseText.length > 0) {
//                   data = data.responseText.replace(/[\[\]']+/g,'').split(",")
//                   if(data[1] == undefined)
//                     data[1] = 503
//                   $modal = $('.invoice_err'),
//                   $modalBody = $('.modal-title'),
//                   $modalBody.html('Error : ' + data[0] + '<br>' + 'Error Code : ' + data[1]);
//                   $modal.modal();
//                 }
//               })
//               .done(function(data) {
//                 var message = JSON.parse(data)
//                 if (message["error"]){
//                   set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">'+message['error']['message']+' </h4></div></div></li>';
//                   $(".sending").hide();
//                   $("#instructor_conversation").find('li').first().remove(); 
//                 }
//                 else{
//                   msg_time_created(message["created_at"])
//                   $(".sending").hide();
//                   $('.panel-danger').hide();
//                   if(message["status"] == "queued"){
//                     $("#inst_message_status").html("SMS sent.").show();
//                   }
//                   else{
//                     $("#inst_message_status").html(message["status"]).show();
//                   }
//                   set_tr_conversation = '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ message["to_number"] +' </a> <span class="body replace_str">'+ message["message_description"] +'</span></div><center><small> '+ f_date +'</small></center></li>';
//                 }
//                 $("#instructor_conversation").find('li').first().before(set_tr_conversation);
//             });
//           });
//         }
//         else
//         {
//           $("#instructor_message_template").focus();
//           $("#inst_message_status").html("Message can't be blank.");
//           return false;
//         }
//       }
//     });

//     $("#customer_message_send").click(function(){
//       var customer = $("#lead_contact").text().replace(/\s+/g, '');
//       var message_body = $("#customer_message_template").val();
//       if(message_body != "") {
//         $.ajax({
//           url: '/manage/job_message_send',
//           type: 'get',
//           data: { customer: customer, message_body: message_body, job_id: job_h_id },
//           beforeSend : function(){
//             $("#cust_message_status").html("Sending SMS...").show();
//             set_tr_conversation = '<li class="out sending"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message" style="background-color: pink;"><span class="arrow"></span>  <a class="name" href="#">'+ $("#lead_contact").text() +' </a> <span class="datetime"> sending...</span><span class="body replace_str">'+ $("#customer_message_template").val(); +'</span></div></li>';
//             $("#customer_conversation").find('li').first().before(set_tr_conversation);
//             $('.cust_scroller').animate({scrollTop: $('.cust_scroller')[0].scrollHeight}, 'slow');
//             $("#customer_conversation").find('li .panel-danger').closest('li').remove();
//           }
//         })
//         .fail(function(data) {
//           if(data.responseText.length > 0) {
//             data = data.responseText.replace(/[\[\]']+/g,'').split(",")
//             if(data[1] == undefined)
//               data[1] = 503
//             $modal = $('.invoice_err'),
//             $modalBody = $('.modal-title'),
//             $modalBody.html('Error : ' + data[0] + '<br>' + 'Error Code : ' + data[1]);
//             $modal.modal();
//           }
//         })
//         .done(function(data) {
//           var message = JSON.parse(data)
//           if (message["error"]){
//             set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">'+message['error']['message']+' </h4></div></div></li>';
//             $(".sending").hide();
//             $("#customer_conversation").find('li').first().remove();
//           }
//           else{
//             msg_time_created(message["created_at"])
//             $(".sending").hide();

//             if(message["status"] == "queued"){
//               $("#cust_message_status").html("SMS sent.").show();
//             }
//             else{
//               $("#cust_message_status").html(message["status"]).show();
//             }
//             set_tr_conversation = '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ message["to_number"] +' </a> <span class="body replace_str">'+ message["message_description"] +'</span></div><center><small>'+ f_date +'</small></center></li>';
//         }
//         $('#customer_conversation').find('li').first().before(set_tr_conversation);
//         });
//       }
//       else
//       {
//         $("#customer_message_template").focus();
//         $("#cust_message_status").html("Message can't be blank.").show();
//         return false;
//       }
//     });
// // END --> From job show page send messages for cutomer and instructor

// // on page load of job show Conversation will appear according selected instructor in dropdown 
//   // var job_instructor = $("#job_instructor_id").find('option:selected').text();
// function showConversation(str, p_id)
// {
//   if(str == "API_ERROR")
//   {
//     $("#"+p_id).find(".panel-success").hide();
//     $("#"+p_id).html('<li class="in"><h4>Please check your API setting.</h4></li>');
//   }
//   else {
//     if(str.length > 0) {
//       var arr_t = [];
//       var htmlString = '';
//       var phone_id = str.c_phone_number;
//       var cst_phone_id = $("#lead_contact").text().trim();
//       var next_marker = str.next_marker;
//       // $.each(str.data, function(idx, obj) {
//       //   arr_t.unshift(obj);
//       // });
//       arr_t = str;
//       for(var i=0; i < arr_t.length; i++) {
//         obj = arr_t[i];
//         msg_time_created(obj.created_at)
//         if(obj.direction == "incoming")
//           htmlString += '<li class="in"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.message_description +'</span></div><center><small>'+ f_date +'</small></center></li>';
//         else
//           htmlString += '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.message_description +'</span></div><center><small>'+ f_date +'</small></center></li>';
//       }
//       if(next_marker == null)
//         $("#" + p_id).html(htmlString);
//       else
//         $("#" + p_id).html(htmlString);
//     }
//     else {
//       var set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title"> No conversation found!!!</h4></div></div></li>';
//       $("#" + p_id).html(set_tr_conversation);
//     }
//   }
// }

// // function showConversationOnScroll(str, p_id)
// // {
// //   // console.log(str.data)
// //   if(str.data != "") {
// //     var arr_t = [];
// //     var htmlString = '';
// //     var phone_id = str.c_phone_number;
// //     var cst_phone_id = $("#lead_contact").text().trim();
// //     var next_marker = str.next_marker;
// //     // $.each(str.data, function(idx, obj) {
// //     //   arr_t.unshift(obj);
// //     // });
// //     arr_t = str.data;
// //     for(var i=0; i < arr_t.length; i++) {
// //       obj = arr_t[i];
// //       msg_time_created(obj.created_at)
// //       if(obj.direction == "incoming")
// //         htmlString += '<li class="in"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.content +'</span></div><center><small>'+ f_date +'</small></center></li>';
// //       else
// //         htmlString += '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.content +'</span></div><center><small>'+ f_date +'</small></center></li>';
// //     }
// //     if(next_marker == null)
// //       $("#"+ p_id).find('li').last().after(htmlString);
// //     else
// //       $("#"+ p_id).find('li').last().after(htmlString);
// //   }
// //   else {
// //     var set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title"> No conversation found!!!</h4></div></div></li>';
// //     $("#" + p_id).html(set_tr_conversation);
// //   }
// // }


// function msg_time_created(time_created) {
//   var arr_month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//   var md = new Date(time_created);
//   utc = md.getTime() + (md.getTimezoneOffset() * 60000);
//   dd = new Date(utc + (3600000*8));
//   var date = dd.getDate();
//   var month = arr_month[dd.getMonth()];
//   var year = dd.getFullYear();
  
//   var hr = dd.getHours();
//   var maridian = "AM";
//   if(hr >= 12) {
//     hr -= 12;
//     maridian = "PM";
//   }
//   var mnt = dd.getMinutes();
//   if(mnt < 10)
//     mnt = "0"+mnt;
//   else if(mnt.length == 1)
//     mnt = mnt+"0"

//   f_date = date + " " + month + " " + year + ", " + hr + ":" + mnt + " " + maridian;
//   return f_date;
// }

// // Conversation on job according to instructor selected from drop-down
// $("#job_instructor_id").change(function(){
//   var instructor = $("#job_instructor_id").find('option:selected').text();
//   instructor = $.trim(instructor.substring(0, instructor.indexOf('-')));
//   var nil = "";
//   if(instructor != ""){
//     $.ajax({
//       url: '/manage/job_conversation',
//       type: 'GET',
//       dataType: 'json',
//       data: { instructor: instructor },
//       beforeSend : function(){
//         $("#instructor_conversation").html('<li style="margin-top: 60%;"><div class="panel panel-success"><div class="panel-heading"><h4 class="panel-title">Loading...</h4></div></div></li>');
//       }
//     })
//     .done(function(data) {
//       if($("#instructor_conversation_load_msg").is(":visible")){
//         $("#instructor_conversation_load_msg").remove();
//       }
//       showConversation(data, "instructor_conversation")
//       $('.inst_scroller').animate({scrollTop: $('#instructor_conversation li:last-child').position().top}, 'slow');
//       var inst_number = data.mobile;
//       $("#inst_number").html(inst_number);
//     });
//    } 
//   else {
//     var error_msg = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">No conversation found</h4></div></div></li>';
//     $("#instructor_conversation").html(error_msg);
//   }
// });

// // $(document).ready(function() {
// //   var instructor = $("#job_instructor_id").find('option:selected').text();
// //   var customer = $("#lead_contact").text().trim();
// //   instructor = $.trim(instructor.substring(0, instructor.indexOf('-')));
// //   if(instructor != "") {
// //     $.ajax({
// //       url: '/manage/message/job_view_message_conversation',
// //       type: 'GET',
// //       dataType: 'json',
// //       data: { instructor: instructor },
// //       beforeSend : function(){
// //         $("#instructor_conversation").html('<li style="margin-top: 60%;"><div class="panel panel-success"><div class="panel-heading"><h4 class="panel-title">Loading...</h4></div></div></li>');
// //       }
// //     })
// //     .fail(function (e) {
// //       showConversation("API_ERROR", "instructor_conversation");
// //     })
// //     .done(function(data) {
// //       if(data != "") {
// //         var arr_t = [];
// //         var htmlString = '';
// //         var phone_id = data.c_phone_number;
// //         var cst_phone_id = $("#lead_contact").text().trim();

// //         arr_t = data;
// //         for(var i=0; i < arr_t.length; i++) {
// //           obj = arr_t[i];
// //           msg_time_created(obj.created_at)
          
// //           if(obj.direction.toLowerCase() == "incoming")
// //             htmlString += '<li class="in"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.message_description +'</span></div><center><small>'+ f_date +'</small></center></li>';
// //           else
// //             htmlString += '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.message_description +'</span></div><center><small>'+ f_date +'</small></center></li>';
// //         }
// //       }
// //       else {
// //         var set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title"> No conversation found!!!</h4></div></div></li>';
// //         $('#instructor_conversation').html(set_tr_conversation);
// //       }
// //       $("#instructor_conversation").html(htmlString)
// //       $('.inst_scroller').animate({scrollTop: $('#instructor_conversation li:last-child').position().top}, 'slow');
// //     });
// //    } 
// //   else {
// //     var error_msg = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">No conversation found</h4></div></div></li>';
// //     $("#instructor_conversation").html(error_msg);
// //   }

// //   if(customer != "") {
// //     var job_h_id = $("#job_h_id").val();
// //     $.ajax({
// //       url: '/manage/message/job_view_customer_conversation',
// //       type: 'GET',
// //       dataType: 'json',
// //       data: { customer: customer, job_id: job_h_id },
// //       beforeSend : function(){
// //         $("#customer_conversation").html('<li style="margin-top: 60%;"><div class="panel panel-success"><div class="panel-heading"><h4 class="panel-title">Loading...</h4></div></div></li>');
// //       }
// //     })
// //     .fail(function (e) {
// //       showConversation("API_ERROR", "customer_conversation");
// //     })
// //     .done(function(data) {
// //       if(data != "") {
// //         var arr_t = [];
// //         var htmlString = '';
// //         var phone_id = data.c_phone_number;
// //         var cst_phone_id = $("#lead_contact").text().trim();

// //         arr_t = data;
// //         for(var i=0; i < arr_t.length; i++) {
// //           obj = arr_t[i];
// //           msg_time_created(obj.created_at)

// //           if(obj.direction.toLowerCase() == "incoming")
// //             htmlString += '<li class="in"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.message_description +'</span></div><center><small>'+ f_date +'</small></center></li>';
// //           else
// //             htmlString += '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.message_description +'</span></div><center><small>'+ f_date +'</small></center></li>';
// //         }
// //       }
// //       else {
// //         var set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title"> No conversation found!!!</h4></div></div></li>';
// //         $("#customer_conversation").html(set_tr_conversation);
// //       }
// //       $("#customer_conversation").html(htmlString)
// //       $(".caption").find("#cust_number").html(data.contact_number);
// //       $('.cust_scroller').animate({scrollTop: $('#customer_conversation li:last-child').position().top}, 'slow');
// //     });
// //   }
// //   else {
// //     var error_msg = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">No conversation found</h4></div></div></li>';
// //     $("#customer_conversation").html(error_msg);
// //   }
// // });

var f_date;
var job_h_id = $("#job_h_id").val();
var messg_b = "";
var baseUrl = window.location.origin;

// START --> From job show page send messages for cutomer and instructor
    $("#instructor_send_message").click(function(){
      var instructor = $("#job_instructor_id").find('option:selected').text();
      if(instructor == "Please Select"){
        alert("Please select instructor to send message!")
      }
      else{
        var message_body = $("#instructor_message_template").val();
        if(message_body != "") {
          instructor = $.trim(instructor.substring(0, instructor.indexOf('-')));
          $.ajax({
            url: '/manage/get_instructor',
            type: 'get',
            data: { instructor: instructor },
          })
          .done(function(data) {
            var inst_to_number = data;
            $.ajax({
              url: '/manage/job_message_send',
              type: 'get',
              data: { instructor: instructor , message_body: message_body, job_id: job_h_id, messg_b: messg_b },
              beforeSend : function(){
                $("#inst_message_status").html("Sending SMS...").show();
                set_tr_conversation = '<li class="out sending"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message" style="background-color: pink;"><span class="arrow"></span>  <a class="name" href="#">'+ inst_to_number +' </a> <span class="datetime"> sending...</span><span class="body replace_str">'+ $("#instructor_message_template").val(); +'</span></div></li>';
                $("#instructor_conversation").find('li').first().before(set_tr_conversation);
                $('.inst_scroller').animate({scrollTop: $('.inst_scroller')[0].scrollHeight}, 'slow');
              }
              })
              .fail(function(data) {
                if(data.responseText.length > 0) {
                  data = data.responseText.replace(/[\[\]']+/g,'').split(",")
                  if(data[1] == undefined)
                    data[1] = 503
                  $modal = $('.invoice_err'),
                  $modalBody = $('.modal-title'),
                  $modalBody.html('Error : ' + data[0] + '<br>' + 'Error Code : ' + data[1]);
                  $modal.modal();
                }
              })
              .done(function(data) {
                var message = JSON.parse(data)
                msg_time_created(message["time_created"])
                $(".sending").hide();
                if(message["status"] == "queued"){
                  $("#inst_message_status").html("SMS sent.").show();
                }
                else{
                  $("#inst_message_status").html(message["status"]).show();
                }
                set_tr_conversation = '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ message["to_number"] +' </a> <span class="body replace_str">'+ message["content"] +'</span></div><center><small> '+ f_date +'</small></center></li>';
                $("#instructor_conversation").find('li').first().before(set_tr_conversation);

            });
          });
        }
        else
        {
          $("#instructor_message_template").focus();
          $("#inst_message_status").html("Message can't be blank.");
          return false;
        }
      }
    });

    $("#customer_message_send").click(function(){
      var customer = $("#lead_contact").text().replace(/\s+/g, '');
      var message_body = $("#customer_message_template").val();
      if(message_body != "") {
        $.ajax({
          url: '/manage/job_message_send',
          type: 'get',
          data: { customer: customer, message_body: message_body, job_id: job_h_id },
          beforeSend : function(){
            $("#cust_message_status").html("Sending SMS...").show();
            set_tr_conversation = '<li class="out sending"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message" style="background-color: pink;"><span class="arrow"></span>  <a class="name" href="#">'+ $("#lead_contact").text() +' </a> <span class="datetime"> sending...</span><span class="body replace_str">'+ $("#customer_message_template").val(); +'</span></div></li>';
            $("#customer_conversation").find('li').first().before(set_tr_conversation);
            $('.cust_scroller').animate({scrollTop: $('.cust_scroller')[0].scrollHeight}, 'slow');
          }
        })
        .fail(function(data) {
          if(data.responseText.length > 0) {
            data = data.responseText.replace(/[\[\]']+/g,'').split(",")
            if(data[1] == undefined)
              data[1] = 503
            $modal = $('.invoice_err'),
            $modalBody = $('.modal-title'),
            $modalBody.html('Error : ' + data[0] + '<br>' + 'Error Code : ' + data[1]);
            $modal.modal();
          }
        })
        .done(function(data) {
          var message = JSON.parse(data)
          msg_time_created(message["time_created"])
          $(".sending").hide();
          if(message["status"] == "queued"){
            $("#cust_message_status").html("SMS sent.").show();
          }
          else{
            $("#cust_message_status").html(message["status"]).show();
          }
          set_tr_conversation = '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ message["to_number"] +' </a> <span class="body replace_str">'+ message["content"] +'</span></div><center><small>'+ f_date +'</small></center></li>';
          $("#customer_conversation").find('li').first().before(set_tr_conversation);
        });
      }
      else
      {
        $("#customer_message_template").focus();
        $("#cust_message_status").html("Message can't be blank.").show();
        return false;
      }
    });
// END --> From job show page send messages for cutomer and instructor

// on page load of job show Conversation will appear according selected instructor in dropdown 
  // var job_instructor = $("#job_instructor_id").find('option:selected').text();
function showConversation(str, p_id)
{
  if(str == "API_ERROR")
  {
    $("#"+p_id).find(".panel-success").hide();
    $("#"+p_id).html('<li class="in"><h4>Please check your API setting.</h4></li>');
  }
  else {
    if(str != "") {
      var arr_t = [];
      var htmlString = '';
      // var phone_id = str.c_phone_number;
      var cst_phone_id = $("#lead_contact").text().trim();
      // var next_marker = str.next_marker;
      // $.each(str.data, function(idx, obj) {
      //   arr_t.unshift(obj);
      // });

      arr_t = str;
      console.log($(arr_t).length)
      for(var i=0; i < $(arr_t).length; i++) {
        obj = arr_t[i];
        msg_time_created(obj.time_created)
        if(obj.direction == "incoming")
          htmlString += '<li class="in"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.content +'</span></div><center><small>'+ f_date +'</small></center></li>';
        else
          htmlString += '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.content +'</span></div><center><small>'+ f_date +'</small></center></li>';
      }
      if(next_marker == null)
        $("#" + p_id).html(htmlString);
      else
        $("#" + p_id).html(htmlString);
    }
    else {
      var set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title"> No conversation found!!!</h4></div></div></li>';
      $("#" + p_id).html(set_tr_conversation);
    }
  }
}

function showConversationOnScroll(str, p_id)
{
  // console.log(str.data)
  if(str.data != "") {
    var arr_t = [];
    var htmlString = '';
    var phone_id = str.c_phone_number;
    var cst_phone_id = $("#lead_contact").text().trim();
    var next_marker = str.next_marker;
    // $.each(str.data, function(idx, obj) {
    //   arr_t.unshift(obj);
    // });
    arr_t = str;
    for(var i=0; i < arr_t.length; i++) {
      obj = arr_t[i];
      msg_time_created(obj.time_created)
      if(obj.direction == "incoming")
        htmlString += '<li class="in"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.content +'</span></div><center><small>'+ f_date +'</small></center></li>';
      else
        htmlString += '<li class="out"><img class="avatar img-responsive" src="/assets/avatar.png" /><div class="message"><span class="arrow"></span>  <a class="name" href="#">'+ obj.from_number +' </a> <span class="body replace_str">'+ obj.content +'</span></div><center><small>'+ f_date +'</small></center></li>';
    }
    if(next_marker == null)
      $("#"+ p_id).find('li').last().after(htmlString);
    else
      $("#"+ p_id).find('li').last().after(htmlString);
  }
  else {
    var set_tr_conversation = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title"> No conversation found!!!</h4></div></div></li>';
    $("#" + p_id).html(set_tr_conversation);
  }
}


function msg_time_created(time_created) {
  var arr_month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  var md = new Date(time_created * 1000);
  utc = md.getTime() + (md.getTimezoneOffset() * 60000);
  dd = new Date(utc + (3600000*8));
  var date = dd.getDate();
  var month = arr_month[dd.getMonth()];
  var year = dd.getFullYear();
  
  var hr = dd.getHours();
  var maridian = "AM";
  if(hr >= 12) {
    hr -= 12;
    maridian = "PM";
  }
  var mnt = dd.getMinutes();
  if(mnt < 10)
    mnt = "0"+mnt;
  else if(mnt.length == 1)
    mnt = mnt+"0"

  f_date = date + " " + month + " " + year + ", " + hr + ":" + mnt + " " + maridian;
  return f_date;
}

// Conversation on job according to instructor selected from drop-down
$("#job_instructor_id").change(function(){
  var instructor = $("#job_instructor_id").val();
  // instructor = $.trim(instructor.substring(0, instructor.indexOf('-')));
  var nil = "";
  if(instructor != ""){
    $.ajax({
      url: '/manage/job_conversation',
      type: 'GET',
      dataType: 'script',
      data: { instructor: instructor },
      beforeSend : function(){
        $("#instructor_conversation").html('<li style="margin-top: 60%;"><div class="panel panel-success"><div class="panel-heading"><h4 class="panel-title">Loading...</h4></div></div></li>');
      }
    })
    .done(function(data) {
      if($("#instructor_conversation_load_msg").is(":visible")){
        $("#instructor_conversation_load_msg").remove();
      }
      showConversation(data, "instructor_conversation")
      $('.inst_scroller').animate({scrollTop: $('#instructor_conversation li:last-child').position().top}, 'slow');
      var inst_number = data.instructorName;
      $("#inst_number").html('<a href="'+baseUrl+'/manage/instructors/'+data.instructorId+'">'+inst_number+'</a>').attr("data-mobile", data.mobile);;
    });
   } 
  else {
    var error_msg = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">No conversation found</h4></div></div></li>';
    $("#instructor_conversation").html(error_msg);
  }
});

$(document).ready(function() {
  var instructor = $("#job_instructor_id").val();
  var customer = $("#lead_contact").text().trim();
  // instructor = $.trim(instructor.substring(0, instructor.indexOf('-')));
  if(instructor != "") {
    $.ajax({
      url: '/manage/job_conversation',
      type: 'GET',
      dataType: 'script',
      data: { instructor: instructor },
      beforeSend : function(){
        $("#instructor_conversation").html('<li style="margin-top: 60%;"><div class="panel panel-success"><div class="panel-heading"><h4 class="panel-title">Loading...</h4></div></div></li>');
      }
    })
    // .fail(function (e) {
    //   $('#instructor_conversation').html('<li class="in"><h4>Please check your API setting.</h4></li>');
    // })
    // .done(function(data) {
    //   $(".next_marker_inst").val(data.next_marker);
    //   showConversation(data, "instructor_conversation")
    //   $(".caption").find("#inst_number").html('<a href="'+baseUrl+'/manage/instructors/'+data.instructorId+'">'+data.instructorName+'</a>').attr("data-mobile", data.mobile);
    //   // $('.inst_scroller').animate({scrollTop: $('#instructor_conversation li:last-child').position().top}, 'slow');
    // });
   } 
  else {
    var error_msg = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">No conversation found</h4></div></div></li>';
    $("#instructor_conversation").html(error_msg);
  }

  if(customer != "") {
    var job_h_id = $("#job_h_id").val();
    $.ajax({
      url: '/manage/customer_job_conversation',
      type: 'GET',
      dataType: 'script',
      data: { customer: customer, job_id: job_h_id },
      beforeSend : function(){
        $("#customer_conversation").html('<li style="margin-top: 60%;"><div class="panel panel-success"><div class="panel-heading"><h4 class="panel-title">Loading...</h4></div></div></li>');
      }
    })
    // .fail(function (e) {
    //   // showConversation("API_ERROR", "customer_conversation");
    //   // $('#customer_conversation').html('<li class="in"><h4>Please check your API setting.</h4></li>')
    // })
    // .done(function(data) {
    //   $(".next_marker_cust").val(data.next_marker);
    //   showConversation(data, "customer_conversation")
    //   $(".caption").find("#cust_number").html(data.contact_number);
    //   $('.cust_scroller').animate({scrollTop: $('#customer_conversation li:last-child').position().top}, 'slow');
    // });
  }
  else {
    var error_msg = '<li><div class="panel panel-danger"><div class="panel-heading"><h4 class="panel-title">No conversation found</h4></div></div></li>';
    $("#customer_conversation").html(error_msg);
  }
});