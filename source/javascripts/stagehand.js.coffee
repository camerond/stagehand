# Stagehand
# version 0.4.1
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
  afterSceneChange: $.noop()
  stages: {}
  stage_controls: []
  templates:
    controls: "<section id='stagehand-controls'><h1>Stagehand</h1><ul></ul></section>"
    control: "<li><h2></h2><ul></ul></li>"
    control_button: "<li><a href='#'></a></li>"
    toggle: "<a href='#' class='stagehand-toggle'></a>"
  saveState: ->
    scenes = {}
    for $control in @stage_controls
      $active = $control.find('.stagehand-active')
      if $active.length
        scenes[$control.attr('data-stage')] = $active.attr('data-scene-control')
    sessionStorage.setItem("stagehand-scenes", JSON.stringify(scenes))
    sessionStorage.setItem("stagehand-toggle", $("body").is(".stagehand-active"))
  loadState: ->
    $(document.body).toggleClass('stagehand-active', sessionStorage.getItem('stagehand-toggle') == 'true')
    for stage, scene of JSON.parse(sessionStorage.getItem("stagehand-scenes"))
      @$controls.find("[data-stage='#{stage}'] [data-scene-control='#{scene}']").trigger('click.stagehand')
    @$controls.find("[data-stage]").each ->
      if !$(@).find('.stagehand-active').length
        $(@).find('a').eq(0).trigger('click.stagehand')
  teardown: ->
    @$controls.remove()
    @$el.removeData(@name)
    sessionStorage.setItem("stagehand-scenes", false)
    sessionStorage.setItem("stagehand-toggle", false)
  buildControls: ->
    if @$controls
      @$controls.empty()
    else
      @$controls = $(@templates.controls).append($(@templates.toggle))
      $(document.body).append(@$controls)
    for k, v of @stages
      @buildStageControl(k, v)
  buildStageControl: (name, $stage) ->
    s = @
    $li = $(@templates.control)
    $li
      .attr('data-stage', name)
      .find('h2').text(name)
    $stage.each (idx) ->
      $button = s.buildOrAppendControlButton($(@), $li, idx)
    @prependSpecialOptions($li, $stage)
    $li.find('a').data('$stage', $stage)
    @stage_controls.push($li)
    @$controls.find("> ul").append($li)
  prependSpecialOptions: ($li, $stage) ->
    special = []
    if $stage.filter("[data-scene='all']").length
      special.push('none')
    if $stage.filter("[data-scene='toggle']").length
      special.push('toggle on')
      special.push('toggle off')
    for txt in special
      $button = $(@templates.control_button)
        .prependTo($li.find('ul'))
        .find('a').text(txt)
        .attr('data-scene-control', "special-#{txt.replace(' ', '-')}")
  buildOrAppendControlButton: ($actor, $control, idx) ->
    scenes = if $actor.attr('data-scene') then $actor.attr('data-scene').split(',') else ["#{idx + 1}"]
    for scene, i in scenes
      if scene == 'all' or scene == 'toggle' then return
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
  changeScene: (e) ->
    s = @
    $a = $(e.target)
    $actors_on = $actors_off = $()
    if $a.is("[data-scene-control^='special']")
      switch $a.text()
        when 'none'
          $actors_off = $a.data('$stage')
        when 'toggle off'
          $actors_off = $a.data('$stage').filter("[data-scene='toggle']")
        when 'toggle on'
          $actors_on = $a.data('$stage').filter("[data-scene='toggle']")
    else
      $actors_on = $a.data('$actor').add($a.data('$stage').filter("[data-scene='all']"))
      $actors_off = $a.data('$stage').not($actors_on)
    $a.closest('ul').find('a').removeClass('stagehand-active')
    $a.addClass('stagehand-active')
    $actors_off.each ->
      s.toggleActor $(@), false
    $actors_on.each ->
      s.toggleActor $(@), true
    @afterSceneChange && @afterSceneChange($actors_on, $actors_off)
    @saveState()
    false
  toggleActor: ($actor, direction) ->
    klass = $actor.attr('data-scene-class')
    id = $actor.attr('data-scene-id')
    if klass then $actor.toggleClass(klass, direction)
    if id then $actor.attr("id", if direction then id else '')
    if !id and !klass then $actor.toggle(direction)
  detectNamedStages: ->
    $actor_cache = $.extend(@$actor_elements, {}).filter('[data-stage]').filter("[data-stage!='']")
    while $actor_cache.length
      $actor = $actor_cache.eq(0)
      for stage_name in $actor.attr('data-stage').split(',')
        stage_name = stage_name.replace(/^\s+|\s+$/g, '')
        if @stages[stage_name]
          @stages[stage_name] = @stages[stage_name].add($actor)
        else
          @stages[stage_name] = $actor
      @$actor_elements = @$actor_elements.not($actor)
      $actor_cache = $actor_cache.not($actor)
  detectAnonymousStages: ->
    $actor_cache = $.extend(@$actor_elements, {})
    i = 1
    while $actor_cache.length
      $actor = $actor_cache.eq(0)
      $stage = $actor.add($actor.nextUntil("[data-stage!='']"))
      $stage = $stage.add($actor.prevUntil("[data-stage!='']"))
      @stages["Stage #{i}"] = $stage
      $actor_cache = $actor_cache.not($stage)
      i = i + 1
  detectScenes: ->
    @$actor_elements = @$el.find('[data-stage]')
    @detectNamedStages()
    @detectAnonymousStages()
  toggleControls: ->
    $(document.body).toggleClass('stagehand-active')
    @saveState()
    false
  bindEvents: ->
    @$controls.on 'click.stagehand', 'ul a', $.proxy(@changeScene, @)
    @$controls.on 'click.stagehand', 'a.stagehand-toggle', $.proxy(@toggleControls, @)
  init: ->
    @detectScenes()
    @buildControls()
    @bindEvents()
    @overlay && $(document.body).toggleClass('stagehand-overlay')
    @loadState()
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
