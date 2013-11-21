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
  templates:
    controls: "<div class='stagehand-controls'><p>Stages</p><ul></ul></div>"
    control: "<li><label></label><select></select></li>"
  teardown: ->
    @$controls.remove()
    @$el.removeData(@name)
  buildControls: ->
    if @$controls
      @$controls.empty()
    else
      @$controls = $(@templates.controls).appendTo($(document.body))
    for $stage, i in @stages
      @buildStageControl($stage, i)
  buildStageControl: ($stage, i) ->
    $control = $(@templates.control)
    stage_name = $stage.attr('data-stage') || "Stage #{i+1}"
    $control.find('label').text(stage_name)
    $select = $control.find('select')
      .attr('data-stage-name', stage_name)
      .data('stage', $stage)
    $stage.each (idx) ->
      text = if $(@).attr('data-scene') then $(@).attr('data-scene') else "Scene #{idx + 1}"
      $('<option />')
        .attr('value', idx)
        .text(text)
        .data('actor', $(@))
        .appendTo($select)
    @$controls.append($control)
  changeScene: ->
    $(@).data('stage').hide()
    $(@).find(':selected').data('actor').show()
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
  bindEvents: ->
    @$controls.on 'change.stagehand', 'select', @changeScene
  init: ->
    @detectScenes(@$el)
    @bindEvents()
    @$controls.find('select').trigger('change.stagehand')
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
