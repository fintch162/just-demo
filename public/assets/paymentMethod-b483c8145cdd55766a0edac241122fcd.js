var apiKey = $("#xfersKey").val();
var myXfer = new Xfers();
var userEmail = $("#customerEmail").val();
var amount = $("#totalAmount").val();
var shipping = 0;
var tax = 0;
var totalAmount = 0;
var refundable = "false";
var queryStr = "?amount="+amount+"&customer="+userEmail+"&payment_method=xfers"
function buy(notify_url, jobId) {
  var orderName = "REF - "+ jobId + " (Invoice " +$("#invoiceId").val() + ")";
  $("#xfersiframe").closest('div').css({"z-index":"999"});
  $(".bank_transfer").text("Please wait...");
  var returnUrl = "<%= success_url(params[:id], params[:u_sec_number]) %>"; 
  var items = [];
  var currency = 'SGD'
  items.push(new myXfer.Item(orderName, amount, 1, '', ''));
  myXfer.makePayment(apiKey, orderName, shipping, tax, items,
     amount, currency, userEmail,
     window.location.pathname,
     window.location.pathname.replace('s','')+queryStr,
     notify_url,
     "false");
}

$(".paypal").click(function(){
  $(".paypal").text("Please wait...");
  $(".paypal").addClass('disabled');
});

// 6JN80040HH4160231
;
