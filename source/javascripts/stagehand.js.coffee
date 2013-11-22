# Stagehand
# version 0.1
#
# Copyright (c) 2013 Cameron Daigle, http://camerondaigle.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Stagehand =
  name: 'stagehand'
  named_stages: {}
  stages: []
  stage_controls: []
  templates:
    controls: "<section id='stagehand-controls'><h1>Stagehand</h1><ul></ul></section>"
    control: "<li><h2></h2><ul></ul></li>"
    control_button: "<li><a href='#'></a></li>"
    toggle: "<a href='#' class='stagehand-toggle'></a>"
  teardown: ->
    @$controls.remove()
    @$el.removeData(@name)
  buildControls: ->
    if @$controls
      @$controls.empty()
    else
      @$controls = $(@templates.controls).append($(@templates.toggle))
      $(document.body).append(@$controls).addClass('.stagehand-enabled')
    for $stage, i in @stages
      @buildStageControl($stage, i)
  buildStageControl: ($stage, i) ->
    s = @
    $li = $(@templates.control)
    stage_name = $stage.attr('data-stage') || "Stage #{i+1}"
    $li
      .attr('data-stage', stage_name)
      .find('h2').text(stage_name)
    $stage.each (idx) ->
      $button = s.buildOrAppendControlButton($(@), $li, idx)
      $button.data('$stage', $stage)
    @stage_controls.push($li)
    @$controls.find("> ul").append($li)
  buildOrAppendControlButton: ($actor, $control, idx) ->
    scenes = if $actor.attr('data-scene') then $actor.attr('data-scene').split(',') else ["#{idx + 1}"]
    for scene, i in scenes
      scene = scene.replace(/^\s+|\s+$/g, '')
      $button = $control.find("[data-scene-control='#{scene}']")
      if $button.length
        $button.data('$actor', $button.data('$actor').add($actor))
      else
        $button = $(@templates.control_button)
          .appendTo($control.find('ul'))
          .find('a')
            .attr('data-scene-control', scene)
            .data('$actor', $actor)
            .text(scene)
    $button
  changeScene: ->
    $a = $(@)
    $a.closest('ul').find('a').removeClass('stagehand-active')
    $a.addClass('stagehand-active')
    $a.data('$stage').hide()
    $a.data('$actor').show()
    false
  detectNamedStages: ->
    $actor_cache = $.extend(@$actor_elements, {}).filter('[data-stage]').filter("[data-stage!='']")
    while $actor_cache.length
      $actor = $actor_cache.eq(0)
      stage_name = $actor.attr('data-stage')
      $stage = $actor.add($actor_cache.filter("[data-stage='#{stage_name}']"))
      @$actor_elements = @$actor_elements.not($stage)
      $actor_cache = $actor_cache.not($stage)
      if $stage.length > 1
        @named_stages[stage_name] = $stage
        @stages.push($stage)
  detectAnonymousStages: ->
    $actor_cache = $.extend(@$actor_elements, {})
    while $actor_cache.length
      $actor = $actor_cache.eq(0)
      $stage = $actor.add($actor.nextUntil("[data-stage!='']"))
      $stage = $stage.add($actor.prevUntil("[data-stage!='']"))
      $stage.length > 1 && @stages.push($stage)
      $actor_cache = $actor_cache.not($stage)
  detectScenes: ($context) ->
    @$actor_elements = $context.find('[data-stage]')
    @detectNamedStages()
    @detectAnonymousStages()
    @buildControls()
  toggleControls: ->
    $(document.body).toggleClass('stagehand-active')
    false
  bindEvents: ->
    @$controls.on 'click.stagehand', 'ul a', @changeScene
    @$controls.on 'click.stagehand', 'a.stagehand-toggle', @toggleControls
  init: ->
    @detectScenes(@$el)
    @bindEvents()
    $.each @stage_controls, ->
      $(@).find('a').eq(0).trigger('click.stagehand')
    @$el

$.fn[Stagehand.name] = (opts) ->
  $els = @
  method = if $.isPlainObject(opts) or !opts then '' else opts
  if method and Stagehand[method]
    Stagehand[method].apply($els, Array.prototype.slice.call(arguments, 1))
  else if !method
    $els.each ->
      plugin_instance = $.extend(
        true,
        $el: $(@),
        Stagehand,
        opts
      )
      $(@).data(Stagehand.name, plugin_instance)
      plugin_instance.init()
  else
    $.error('Method #{method} does not exist on jQuery. #{Stagehand.name}');
  return $els;
