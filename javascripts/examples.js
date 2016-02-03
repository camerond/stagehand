(function() {
  $(function() {
    var $body, $code;

    $body = $(document.body);
    $code = $body.find('pre code').remove();
    Stagehand.init();
    return $body.find('pre').append($code);
  });

}).call(this);
