# Stagehand
# version 0.4.3
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

class Stage
  constructor: (@name) ->
    @scenes = {}
    @keyword_scenes = {}
    @$els = $()
    @$el = $(@template)
    @$el.find('h2').text(name)
    @$default = false
  template: "<li><h2></h2><ul></ul></li>"
  addEls: ($els) ->
    @$els = @$els.add($els)
  initialize: ->
    (@$default || @$el.find('a:first')).click()
  parseScenes: ->
    idx = 0
    @$els.each (k, v) =>
      $el = $(v)
      names = if $el.attr('data-scene') then $el.attr('data-scene').split(',')
      for scene_name in names || [idx = idx + 1]
        scene_name = ('' + scene_name).replace(/^\s?!?|\s+$/g, '')
        new_scene = @addScene(scene_name)
        new_scene.addActor($el)
        $el.is('[data-default-scene]') && @setDefault(new_scene)
  addScene: (name) ->
    if name == 'all'
      @appendNoneOption()
      return @keyword_scenes.all ||= new AllScene(@)
    if !@scenes[name]
      @scenes[name] = new Scene(@, name)
      @$el.find('ul').append(@scenes[name].$el)
    return @scenes[name]
  appendNoneOption: ->
    if !@keyword_scenes.none
      @keyword_scenes.none = new NoneScene(@)
      @$el.find('ul').prepend(@keyword_scenes.none.$el)
    @scenes['none']
  setDefault: (scene) ->
    @$default = scene.$el.find('a')
  toggleScene: (name) ->
    (@scenes[name] || @keyword_scenes[name]).handleClick()

class Scene
  constructor: (@stage, @name) ->
    @$actors = $()
    @$exclusions = $()
    @$el = $(@template)
    @$el.data('scene', @)
    @$el.find('a').text(@name)
  template: "<li><a href='#'></a></li>"
  addActor: ($el) ->
    if $el.attr('data-scene')?.indexOf("!#{@name}") > -1
      @$exclusions = @$exclusions.add($el)
    else
      @$actors = @$actors.add($el)
    @
  toggleKeywordAll: ->
    @stage.keyword_scenes.all && @stage.keyword_scenes.all.toggle(true)
  handleClick: ->
    for k, scene of @stage.scenes
      scene.name != @name && scene.toggle(false)
    @toggleKeywordAll()
    @toggle(true)
  toggleActors: ($actors, direction) ->
    $actors.each ->
      $actor = $(@)
      klass = $actor.attr('data-scene-class')
      id = $actor.attr('data-scene-id')
      if klass then $actor.toggleClass(klass, direction)
      if id then $actor.attr("id", if direction then id else '')
      if !id and !klass then $actor.toggle(direction)
  toggle: (direction) ->
    @$el.toggleClass('stagehand-active', direction)
    @toggleActors(@$exclusions, false)
    @toggleActors(@$actors.not(@$exclusions), direction)

class AllScene extends Scene
  constructor: (@stage) ->
    super(@stage, 'all')
  @$exclusions: $.noop()

class NoneScene extends Scene
  constructor: (@stage) ->
    super(@stage, 'none')
  toggleKeywordAll: ->
    @stage.keyword_scenes.all.toggle(false)

Stagehand =
  template: "<section id='stagehand-controls'><h1>Stagehand</h1><ul></ul></section>"
  template_toggle: "<a href='#' class='stagehand-toggle'></a>"
  stages: {}
  addStage: (name) ->
    name = name.replace(/^\s+|\s+$/g, '')
    if !@stages[name]
      @stages[name] = new Stage(name)
      @$controls.find('> ul').append(@stages[name].$el)
    @stages[name]
  changeScene: (e) ->
    scene = $(e.target).closest('li').data('scene')
    scene.stage.toggleScene(scene.name)
  parseAnonymousStages: ->
    $anons = @$stage_cache.filter('[data-stage=""]')
    @$stage_cache = @$stage_cache.not($anons)
    idx = 1
    while $anons.length
      $actor = $anons.eq(0)
      $stage = $actor.add($actor.nextUntil("[data-stage!='']"))
      $stage = $stage.add($actor.prevUntil("[data-stage!='']"))
      @addStage("Stage #{idx}").addEls($stage)
      $anons = $anons.not($stage)
      idx = idx + 1
  parseNamedStages: ->
    @$stage_cache.each (k, v) =>
      $actor = $(v)
      for stage_name in $actor.attr('data-stage').split(',')
        @addStage(stage_name).addEls($actor)
  toggleControls: ->
    $(document.body).toggleClass('stagehand-active')
    false
  bindEvents: ->
    @$controls.on 'click.stagehand', 'a.stagehand-toggle', $.proxy(@toggleControls, @)
    @$controls.on 'click.stagehand', 'ul a', $.proxy(@changeScene, @)
  teardown: ->
    @$controls.remove()
    @$el.removeData(@name)
  init: ->
    @$controls = $(@template).appendTo($(document.body))
    @$controls.append($(@template_toggle))
    @$stage_cache = $('[data-stage]')
    @parseAnonymousStages()
    @parseNamedStages()
    @bindEvents()
    for name, stage of @stages
      stage.parseScenes()
      stage.initialize()
    @$el

$.fn.stagehand = (opts) ->
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
      $(@).data('stagehand', plugin_instance)
      plugin_instance.init()
  else
    $.error('Method #{method} does not exist on jQuery.')
  return $els
