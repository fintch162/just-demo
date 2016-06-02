var Index = function () {
  return {
    initDashboardDaterange: function () {
        $('#dashboard-report-range').daterangepicker({
          opens: (Metronic.isRTL() ? 'right' : 'left'),
          startDate: moment().subtract('days', 0),
          endDate: moment(),
          minDate: '01/01/2012',
          showDropdowns: false,
          showWeekNumbers: true,
          timePicker: false,
          timePickerIncrement: 1,
          timePicker12Hour: true,
          buttonClasses: ['btn btn-sm'],
          applyClass: ' blue',
          cancelClass: 'default',
          format: 'MM/DD/YYYY',
          separator: ' to ',
          locale: {
            applyLabel: 'Apply',
            fromLabel: 'From',
            toLabel: 'To',
            customRangeLabel: 'Custom Range',
            daysOfWeek: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
            monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
            firstDay: 1
          }
        },
        function (start, end) {
          var startDate = start.format('YYYY-MM-D');
          var endDate = end.format('YYYY-MM-D');
          $.ajax({
            url: '/manage/filter-data',
            type: 'GET',
            dataType: 'script',
            data: { startDate: startDate, endDate: endDate },
          })
          .done(function() {
          })
          .fail(function() {
          })
          .always(function() {
          });
          $('#dashboard-report-range span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
        }
      );
      $('#dashboard-report-range span').html(moment().subtract('days', 0).format('MMMM D, YYYY') + ' - ' + moment().format('MMMM D, YYYY'));
      $('#dashboard-report-range').show();
    }
  };
}();