$ ->

  # this is a complicated bit to get Stagehand to ignore the example code blocks.
  # normally you'd just say $(document.body).stagehand()
  # not sure this needs to be supported by the actual plugin, so ...

  $body = $(document.body)
  $code = $body.find('pre code').remove()
  Stagehand.init()
  $body.find('pre').append($code)
