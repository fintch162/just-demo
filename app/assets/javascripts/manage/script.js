jQuery.fn.highlight = function (str, className) {
  var regex = new RegExp(str, "gi");
  return this.each(function () {
    $(this).contents().filter(function() {
      return this.nodeType == 3 && regex.test(this.nodeValue);
    }).replaceWith(function() {
      return (this.nodeValue || "").replace(regex, function(match) {
        return "<span class=\"" + className + "\">" + match + "</span>";
      });
    });
  });
};

$(document).ready(function() {
	$('.portlet-body table tr td').highlight($('#search_key').val(),'highlight');
	// $('.caption').highlight('e','highlight');
});
console.log('script');