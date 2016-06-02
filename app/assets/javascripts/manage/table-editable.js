var oTableForEdit,nRowForEdit;
var TableEditable = function () {

    return {

        //main function to initiate the module
        init: function () {
          var oTable;
            function restoreRow(oTable, nRow) {
                var aData = oTable.fnGetData(nRow);
                var jqTds = $('>td', nRow);

                for (var i = 0, iLen = jqTds.length; i < iLen; i++) {
                    oTable.fnUpdate(aData[i], nRow, i, false);
                }

                oTable.fnDraw();
            }

            function editRow(oTable, nRow) {
                
                var aData = oTable.fnGetData(nRow);
                var level_id = $(aData[1]).attr('id');
                var jqTds = $('>td', nRow);
                oTableForEdit = oTable;
                nRowForEdit = nRow;
               if (typeof(level_id) != "undefined")
                 {
                  jqTds[0].innerHTML = '<input type="text" id="level_title'+level_id+'" class="form-control input-small" value="' + aData[0] + '">';
                  jqTds[1].innerHTML = '<a class="edit" href="javascript:void(0);"  onclick="save_level('+level_id+');">Save</a>';
                  jqTds[2].innerHTML = '<a class="cancel" href="">Cancel</a>';
                 }
                else {
                  jqTds[0].innerHTML = '<input type="text" id="level_title" class="form-control input-small" value="' + aData[0] + '">';
                  jqTds[1].innerHTML = '<a class="edit" href="javascript:void(0);"  onclick="save_new_level();">Save</a>';
                  jqTds[2].innerHTML = '<a class="cancel" href="">Cancel</a>';
                }
              
            }

            function saveRow(oTable, nRow) {
                var jqInputs = $('input', nRow);
                oTable.fnUpdate(jqInputs[0].value, nRow, 0, false);
                // oTable.fnUpdate(jqInputs[1].value, nRow, 1, false);
                oTable.fnUpdate('<a class="edit" href="">Edit</a>', nRow, 1, false);
                oTable.fnUpdate('<a class="delete" href="">Delete</a>', nRow, 2, false);
                oTable.fnDraw();
            }

            function cancelEditRow(oTable, nRow) {
                var jqInputs = $('input', nRow);
                oTable.fnUpdate(jqInputs[0].value, nRow, 0, false);
                // oTable.fnUpdate(jqInputs[1].value, nRow, 1, false);
                // oTable.fnUpdate(jqInputs[2].value, nRow, 2, false);
                // oTable.fnUpdate(jqInputs[3].value, nRow, 3, false);
                oTable.fnUpdate('<a class="edit" href="">Edit</a>', nRow, 1, false);
                oTable.fnDraw();
            }

            oTable = $('#sample_editable_1').dataTable({
                "aLengthMenu": [
                    [5, 15, 20, -1],
                    [5, 15, 20, "All"] // change per page values here
                ],
                // set the initial value
                "iDisplayLength": 5,
                
                "sPaginationType": "bootstrap",
                "fnDrawCallback":function(oSettings){
                    bindEvents();
                },
                "oLanguage": {
                    "sLengthMenu": "_MENU_ records",
                    "oPaginate": {
                        "sPrevious": "Prev",
                        "sNext": "Next"
                    }
                 },
                "aoColumnDefs": [{
                        'bSortable': true,
                        'aTargets': [0]
                    }
                ]
            });

            jQuery('#sample_editable_1_wrapper .dataTables_filter input').addClass("form-control input-medium input-inline"); // modify table search input
            jQuery('#sample_editable_1_wrapper .dataTables_length select').addClass("form-control input-small"); // modify table per page dropdown
            // jQuery('#sample_editable_1_wrapper .dataTables_length select').select2({
            //     showSearchInput : false //hide search box with special css class
            // }); // initialize select2 dropdown

            var nEditing = null;

            $('#sample_editable_1_new').click(function (e) {
                
                e.preventDefault();

                if (nEditing) {

                    if (confirm("Previose row not saved. Do you want to save it ?")) {
                        saveRow(oTable, nEditing); // save

                    } else {
                        oTable.fnDeleteRow(nEditing); // cancel
                    }
                }

                var aiNew = oTable.fnAddData(['', '', '', '', '', '']);
                var nRow = oTable.fnGetNodes(aiNew[0]);
                editRow(oTable, nRow);
                nEditing = nRow;
            });

            
            function bindEvents() {
                $('#sample_editable_1 a.edit').on('click', function (e) {
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
                
                $('#sample_editable_1 a.delete').on('click', function (e) {
                e.preventDefault();
                var level_id = $(this).closest('tr').attr('id');
                if (confirm("Are you sure to delete this row ?") == false) {
                    return;
                }

                var nRow = $(this).parents('tr')[0];
                oTable.fnDeleteRow(nRow);

                    var url = "/manage/levels/" + level_id;
                    $.ajax({
                      url: url,
                      type: 'delete'
                    })
                    .done(function(data) {
                      //saveRow(oTableForEdit,nRowForEdit);
                      console.log(data);
                    })
                    .fail(function(e) {
                      console.log(e);
                    })
                    .always(function(e) {
                      console.log("complete");
                    });
               
            });

            $('#sample_editable_1 a.cancel').on('click', function (e) {
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

    function saveRow(oTable, nRow) {
      var jqInputs = $('input', nRow);
      oTable.fnUpdate(jqInputs[0].value, nRow, 0, false);
      // oTable.fnUpdate(jqInputs[1].value, nRow, 1, false);
      oTable.fnUpdate('<a class="edit" href="">Edit</a>', nRow, 1, false);
      oTable.fnUpdate('<a class="delete" href="">Delete</a>', nRow, 2, false);
      oTable.fnDraw();
    }
    function save_level (p_level_id){
        var level_title = $("#level_title"+p_level_id).val();
        if(level_title == "") {
            $("#level_title5").css({"border-color":"red"});
            return false;
        } else {
            var url = "/manage/levels/"+ p_level_id;
          
            $.ajax({
              url: url,
              type: 'put',
              data: {title: level_title},
            })
            .done(function(data) {
              nEditing = null;
                saveRow(oTableForEdit,nRowForEdit);
              console.log(data);
            })
            .fail(function(e) {
              console.log(e);
            })
            .always(function(e) {
              console.log("complete");
            });
        } 
    } 

    function save_new_level (){
        var level_title = $("#level_title").val();
        if(level_title == "") {
            $("#level_title").css({"border-color":"red"});
            return false;
        } else {
            var url = "/manage/levels/";
          
            $.ajax({
              url: url,
              type: 'post',
              data: {title: level_title},
            })
            .done(function(data) {
              saveRow(oTableForEdit,nRowForEdit);
              console.log(data);
            })
            .fail(function(e) {
              console.log(e);
            })
            .always(function(e) {
              console.log("complete");
            });
        } 
    } 
   