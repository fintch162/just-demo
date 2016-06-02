// var SendSMSInGp = function () {
//   var myTransaction1 = [];


//    var sendMessageScrip = function () { 
//     $('.checkedAll').click(function(event) {
//        var selected_group = $(this).attr('id');
//       if(this.checked) {
//         $('.'+selected_group).each(function() {
//           this.checked = true;
//           if($.inArray($(this).val(),myTransaction1)){
//             myTransaction1.push($(this).val());
//             $('.bulk_action_list').prop('disabled', false);
//           }
//         });
//       } else {
//         $('.'+selected_group).each(function() {
//           this.checked = false;
//           if($.inArray($(this).val(),myTransaction1) != -1){
//             myTransaction1.splice($.inArray($(this).val(),myTransaction1), 1);
//             $('.bulk_action_list').prop('disabled', true);
//           }
//         });         
//       }
//       $('#send_message').val(myTransaction1);
//     });

//     $(".check_student").click(function() {
//       if($(this).is(":checked")){
//         var flag = 0;
//         $(".check_student").each(function() {
//           if(!this.checked){
//             flag = 1;
//             console.log($(this).val());
//             $('.bulk_action_list').prop('disabled', false);
//           }
//         })              
//         if(flag == 0) { $(".checkedAll").prop("checked", true); $('.bulk_action_list').prop('disabled', false);}
//         if($.inArray($(this).val(),myTransaction1)){
//           myTransaction1.push($(this).val());
//         }
//       }
//       else {
//         if($.inArray($(this).val(),myTransaction1) != -1){
//           myTransaction1.splice($.inArray($(this).val(),myTransaction1), 1);
//         }
//         $(".checkedAll").prop("checked", false);
//         if ($('.check_student:checked').length == 0){
//           $('.bulk_action_list').prop('disabled', true);
//         }
//       }
//       var id = $(this).attr('id');
//       $('#send_message').val(myTransaction1);
//       $(this).parents(".fields").remove();
//     });
//   };

//   return {
//     init: function () {
//       sendMessageScrip();
//     }
//   };
// }();
