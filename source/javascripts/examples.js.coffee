$ ->

  # this is a complicated bit to get Stagehand to ignore the example code blocks.

  $body = $(document.body)
  $code = $body.find('pre code').remove()
  Stagehand.init()
  $body.find('pre').append($code)
