# Stagehand
# version 0.5.1
#
# Copyright (c) 2015 Cameron Daigle, http://camerondaigle.com
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
    @exclusion_scenes = {}
    @keyword_scenes = {}
    @$els = $()
    @$el = $(@template)
    @$el.find('h2').text(@name)
    @default_scene_idx = false
  template: "<li><h2></h2><ul></ul></li>"
  addEls: ($els) ->
    @$els = @$els.add($els)
  initialize: ->
    if @default_scene_idx?
      @$el.find('li').eq(@default_scene_idx).find('a').click()
    else
      @$el.find('a:first').click()
  parseScenes: ->
    idx = 0
    @$els.each (k, v) =>
      $el = $(v)
      names = if $el.attr('data-scene') then $el.attr('data-scene').split(',')
      for scene_name in names || [idx = idx + 1]
        scene_name = @trimSceneName(scene_name)
        if scene_name[0] == '!'
          @getExclusionScene(scene_name).addActor($el)
          @getAllScene().addActor($el)
        else
          new_scene = @getScene(scene_name).addActor($el)
          if !@default_scene_idx && $el.is('[data-default-scene]')
            @default_scene_idx = new_scene.$el.index()
  getAllScene: ->
    @keyword_scenes.all ||= new AllScene(@)
  getExclusionScene: (name) ->
    name = name.substring(1)
    @exclusion_scenes[name] ||= new ExclusionScene(@, name)
  getScene: (name) ->
    if name == 'all'
      @prependSpecialOption('none', new NoneScene(@))
      return @getAllScene()
    else if name == 'toggle'
      @prependSpecialOption('toggle on')
      @prependSpecialOption('toggle off')
      return @keyword_scenes['toggle on']
    else if !@scenes[name]
      @scenes[name] = new Scene(@, name)
      @$el.find('ul').append(@scenes[name].$el)
    return @scenes[name]
  prependSpecialOption: (name, scene) ->
    s = scene || new Scene(@, name)
    if !@keyword_scenes[name]
      @keyword_scenes[name] = s
      @$el.find('ul').prepend(s.$el)
  trimSceneName: (name) ->
    ('' + name).replace(/^\s?|\s+$/g, '')
  toggleScene: (name) ->
    (@scenes[name] || @keyword_scenes[name]).handleClick()
  verify: ->
    @$el.find('.stagehand-active').data('scene')?.verify()

class Scene
  constructor: (@stage, @name) ->
    @$actors = $()
    @$el = $(@template)
    @$el.data('scene', @).find('a').text(@name)
  template: "<li><a href='#'></a></li>"
  addActor: ($el) ->
    @$actors = @$actors.add($el)
    @
  toggleKeywordAll: ->
    @stage.keyword_scenes.all?.toggle(true)
  toggleOffOtherScenes: ->
    @$el.siblings().removeClass('stagehand-active')
    @stage.keyword_scenes['toggle on']?.toggle(false)
    for k, scene of @stage.scenes
      scene.name != @name && scene.toggle(false)
  handleClick: ->
    @toggleOffOtherScenes()
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
  toggleExclusions: (direction) ->
    @stage.exclusion_scenes[@name]?.toggle(direction)
  toggle: (direction) ->
    @$el.toggleClass('stagehand-active', direction)
    @toggleActors(@$actors, direction)
    @toggleExclusions(!direction)
  verify: ->
    @toggleKeywordAll()
    @toggle(true)

class ExclusionScene extends Scene
  constructor: (@stage, @name) ->
    @$actors = $()
  toggle: (direction) ->
    @toggleActors(@$actors, direction)

class AllScene extends Scene
  constructor: (@stage) ->
    super(@stage, 'all')

class NoneScene extends Scene
  constructor: (@stage) ->
    super(@stage, 'none')
  toggleExclusions: $.noop
  toggleKeywordAll: ->
    @stage.keyword_scenes.all.toggle(false)
  verify: ->
    @toggle(true)

Stagehand =
  afterSceneChange: $.noop
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
    if e then e.preventDefault()
    scene = $(e.target).closest('li').data('scene')
    scene.stage.toggleScene(scene.name)
    for name, stage of @stages
      stage.verify()
    @afterSceneChange(scene.$actors)
    @saveState()
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
  toggleControls: (e) ->
    if e then e.preventDefault()
    $(document.body).toggleClass('stagehand-active')
    @saveState()
    false
  bindEvents: ->
    @$controls.on 'click.stagehand', 'a.stagehand-toggle', $.proxy(@toggleControls, @)
    @$controls.on 'click.stagehand', 'ul a', $.proxy(@changeScene, @)
  teardown: ->
    @$controls.remove()
    @$el.removeData('stagehand')
    sessionStorage.setItem("stagehand-scenes", false)
    sessionStorage.setItem("stagehand-toggle", false)
  saveState: ->
    stages = {}
    for name, stage of @stages
      $active = stage.$el.find('.stagehand-active')
      if $active.length then stages[name] = $active.index()
    sessionStorage.setItem("stagehand-scenes", JSON.stringify(stages))
    sessionStorage.setItem("stagehand-toggle", $(document.body).is(".stagehand-active"))
  loadState: ->
    for stage_name, idx of JSON.parse(sessionStorage.getItem("stagehand-scenes"))
      @stages[stage_name]?.default_scene_idx = idx
    if sessionStorage.getItem('stagehand-toggle') == "true" then @toggleControls()
  init: ->
    @$controls = $(@template).appendTo($(document.body))
    @overlay && $(document.body).addClass('stagehand-overlay')
    @$controls.append($(@template_toggle))
    @$stage_cache = $('[data-stage]')
    @parseAnonymousStages()
    @parseNamedStages()
    @bindEvents()
    @loadState()
    for name, stage of @stages
      stage.parseScenes()
      stage.initialize()
    @$el

$.fn.stagehand = (opts) ->
  $els = @
  method = if $.isPlainObject(opts) or !opts then '' else opts
  $els.each ->
    plugin_instance = $.extend(
      true,
      $el: $(@),
      Stagehand,
      opts
    )
    $(@).data('stagehand', plugin_instance)
    plugin_instance.init()
  return $els
