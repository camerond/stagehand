(function() {
  $(function() {
    var $body, $code;

    $body = $(document.body);
    $code = $body.find('pre code').remove();
    return $body.stagehand().find('pre').append($code);
  });

}).call(this);
