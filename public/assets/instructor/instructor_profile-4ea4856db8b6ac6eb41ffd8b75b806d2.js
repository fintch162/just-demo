(function() {
  $(document).on('change', '#daily_backup_email', function() {
    $.ajax({
      url: '/instructor/update_daily_backup_email_setting',
      type: 'GET',
      data: {
        backup: this.checked
      }
    }).done(function(data) {
      console.log(data);
    }).fail(function() {
      console.log("error");
    });
  });

}).call(this);
