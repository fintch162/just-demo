var isPhone = false;
var isOkStudentName = false;
var isOkStudent_contact = false;
var oTableForEdit,nRowForEdit;
var nEditing = null;
var instructorStudentTableEditable = function () {
    return {
        //main function to initiate the module
        init: function () {
          var oTable;
            function restoreRow(oTable, nRow) {
              var aData = oTable.fnGetData(nRow);
              var jqTds = $('>td', nRow);

              for(var i = 0, iLen = jqTds.length; i < iLen; i++){
                oTable.fnUpdate(aData[i], nRow, i, false);
              }
              oTable.fnDraw();
            }
            function editRow(oTable, nRow) {
              var aData = oTable.fnGetData(nRow);
              var jqTds = $('>td', nRow);
              oTableForEdit = oTable;
              nRowForEdit = nRow;
              jqTds[0].innerHTML = '';
              jqTds[2].innerHTML = '<input type="text" id="student_name" class="form-control input-small" onblur="make_capitalize();">';
              jqTds[3].innerHTML = '<input type="text" id="student_contact" class="form-control input-small validNum">';
              jqTds[5].innerHTML = '<a class="edit" href="" onclick="save_new_student();" data-remote="true">Save</a>';
              jqTds[6].innerHTML = '<a class="cancel" href="">Cancel</a>';
            }

            function saveRow(oTable, nRow) {
              // var jqInputs = $('input', nRow);
              // oTable.fnUpdate(jqInputs[1].value, nRow, 1, false);
              // oTable.fnUpdate(jqInputs[2].value, nRow, 2, false);
              // oTable.fnUpdate('<a class="edit" href="">Edit</a>', nRow, 3, false);
              // oTable.fnUpdate('<a class="delete" href="">Delete</a>', nRow, 4, false);
              // oTable.fnDraw();
              // var previous = $("#previous_date").val(); 
              // var current = $("#current_date").val();
              // var next = $("#next_date").val();
              // var jqInputs = $('input', nRow);
               
              // oTable.fnUpdate(jqInputs[0].value, nRow, 1, false);
              // oTable.fnUpdate(jqInputs[1].value, nRow, 2, false);
              // oTable.fnUpdate('', nRow, 3, false);
              // oTable.fnUpdate('', nRow, 4, false);
              // oTable.fnUpdate('', nRow, 5, false);
              // oTable.fnUpdate('', nRow, 6, false);
              
              // oTable.fnDraw();
            }

            function cancelEditRow(oTable, nRow) {
                var jqInputs = $('input', nRow);
                oTable.fnUpdate(jqInputs[1].value, nRow, 1, false);
                oTable.fnUpdate(jqInputs[2].value, nRow, 2, false);
                oTable.fnUpdate('<a class="edit" href="">Edit</a>', nRow, 3, false);
                oTable.fnDraw();
            }

            oTable = $('.sample_editable_2').dataTable({
              "aLengthMenu": [
                  [5, 15, 20, -1],
                  [5, 15, 20, "All"] // change per page values here
              ],
              responsive: true,
              // set the initial value
              "iDisplayLength": -1,
              "sDom": "frt",
              "paging": false,
              "sPaginationType": "bootstrap",
              "bSort" : false,
              "fnDrawCallback":function(oSettings){
                bindEvents();
                var counter = 0;
                $('.sample_editable_2').find('tr').each(function(elem){
                    $(this).find('td').first().html();
                });
              },
              "oLanguage": {
                "sLengthMenu": "_MENU_ records",
                "oPaginate": {
                    "sPrevious": "Prev",
                    "sNext": "Next"
                },
                "sEmptyTable": "No student records"
               },
              "aoColumnDefs": [{
                  'bSortable': false,
                  'aTargets': [1]
                }
              ]
            });

            jQuery('.sample_editable_2_wrapper .dataTables_filter input').addClass("form-control input-medium input-inline"); // modify table search input
            jQuery('.sample_editable_2_wrapper .dataTables_length select').addClass("form-control input-small"); // modify table per page dropdown

            function validatePhone(data){
              var a = data;
              var filter = /^[+-]?[0-9]+$/;
              
              if(filter.test(a)){
                isPhone = true;
                return isPhone;
              }
              else {
                isPhone = false;
                return isPhone;
              }
            }

            $(document).on('keyup keydown keypress', '.validNum', function(e){
              var a = $(".validNum").val();
              a = a.replace(/\s/g, '');
              a = a.replace(/-/g, '');
              validatePhone(a);
              if(isPhone == true) {
                $(".validNum").closest('td').removeClass('has-error').addClass('has-success');
              }
              else if(isPhone == false) {
                $(".validNum").closest('td').removeClass('has-success').addClass('has-error');
              }
            });

            $('#sample_editable_2_new').click(function (e) {
              if(nEditing) {
                if (confirm("Previose row not saved. Do you want to save it ?")) {
                  saveRow(oTable, nEditing); // save
                } else {
                  oTable.fnDeleteRow(nEditing); // cancel
                }
              }
              var aiNew = oTable.fnAddData(['', '', '', '', '', '', '', '']);
              var nRow = oTable.fnGetNodes(aiNew[0]);
              editRow(oTable, nRow);
              nEditing = nRow;
            });
            
            function bindEvents() {
              $('.sample_editable_2 a.edit').on('click', function (e) {
                  e.preventDefault();
                  /* Get the row as a parent of the link that was clicked on */
                  var nRow = $(this).parents('tr')[0];

                  if (nEditing !== null && nEditing != nRow) {
                      /* Currently editing - but not this row - restore the old before continuing to edit mode */
                      restoreRow(oTable, nEditing);
                      editRow(oTable, nRow);
                      nEditing = nRow;
                  } else if (nEditing == nRow && this.innerHTML == "Save") {
                      /* Editing this row and want to save it */
                      saveRow(oTable, nEditing);
                      nEditing = null;
                      alert("Updated! Do not forget to do some ajax to sync with backend :)");
                  } else {
                      /* No edit in progress - let's start one */
                      editRow(oTable, nRow);
                      nEditing = nRow;
                  }
              });
                
              $('.sample_editable_2 a.delete').on('click', function (e) {
                e.preventDefault();
                var venue_id = $(this).closest('tr').attr('id');
                if (confirm("Are you sure to delete this row ?") == false) {
                    return;
                }

                var nRow = $(this).parents('tr')[0];
                oTable.fnDeleteRow(nRow);

                var url = "/manage/venues/" + venue_id;
                $.ajax({
                  url: url,
                  type: 'delete'
                })
                .done(function(data) {
                  //saveRow(oTableForEdit,nRowForEdit);
                })
                .fail(function(e) {
                })
                .always(function(e) {
                });
              });

            $('.sample_editable_2 a.cancel').on('click', function (e) {
                e.preventDefault();
                if ($(this).attr("data-mode") == "new") {
                    var nRow = $(this).parents('tr')[0];
                    oTable.fnDeleteRow(nRow);
                } else {
                    restoreRow(oTable, nEditing);
                    nEditing = null;
                }
            });
            }
        }

    };
}();

  function saveRow(oTable, nRow, student_id) {
    var previous = $("#previous_date").val(); 
    var current = $("#current_date").val();
    var next = $("#next_date").val();
    var jqInputs = $('input', nRow);
    nEditing = null;
    var chkBox = '<input type="checkbox" class="check_student" value="'+student_id+'" id="checkAll" name="checkAll"></input>';
    oTable.fnUpdate(chkBox, nRow, 1);
    oTable.fnUpdate(jqInputs[0].value, nRow, 2);
    oTable.fnUpdate(jqInputs[1].value, nRow, 3);
    oTable.fnUpdate('', nRow, 5, false);
    oTable.fnUpdate('', nRow, 6, false);
    oTable.fnDraw();
  }
    
  function save_new_student (){
    var student_name = $("#student_name").val();
    var student_contact = $(".validNum").val();
    var groupClassId = $("#groupClassId").val();
    
    if(student_name == "") {
      $("#student_name").closest('td').removeClass('has-success').addClass('has-error');
      isOkStudentName = false;
    }
    else {
      $("#student_name").closest('td').removeClass('has-error').addClass('has-success');
      isOkStudentName = true;
    }
    if(student_contact == "") {
      $(".validNum").closest('td').removeClass('has-success').addClass('has-error');
      $(".validNum").closest('td').find('.cust-err').remove();
      $(".validNum").closest('td').find('input').after("<span class='has-error cust-err'>Invalid Phone Number</span>");
      isOkStudent_contact = false;
    }
    else {
      if(isPhone == true){
        $(".validNum").closest('td').removeClass('has-error').addClass('has-success');
        $(".validNum").closest('td').find('.cust-err').text("");
        isOkStudent_contact = true;
      }
      else {
        $(".validNum").closest('td').find('.cust-err').remove();
        $(".validNum").closest('td').find('input').after("<span class='has-error cust-err'>Invalid Phone Number</span>");
        isOkStudent_contact = false;
      }
    }
    if(isOkStudentName == false || isPhone == false || isOkStudent_contact == false)
      return false;
    else {
      var url = "/instructor/instructor_students";
      $.ajax({
        url: url,
        type: 'post',
        data: {student_name: student_name, contact: student_contact, group_class_id: groupClassId},
      })
      .done(function(data) {
        saveRow(oTableForEdit, nRowForEdit, data);
        nEditing = null;
        window.location.reload();
      })
      .fail(function(e) {
      })
      .always(function(e) {
      });
    }
  }

  function make_capitalize() {
    var name = $("#student_name").val();
    name = name.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
    $('#student_name').val(name);
  }
