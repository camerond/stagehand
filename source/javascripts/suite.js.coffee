$ = jQuery

$.fn.selectorText = () ->
  selector = "%#{@[0].tagName.toLowerCase()}"
  @attr('id') && selector += "##{@.attr('id')}"
  @attr('class') && selector += ".#{@.attr('class')}"
  text = if @text().length > 30 then "#{@text().slice(0, 30)}..." else @text()
  text && selector = selector + " with text of '#{text}'"
  selector

$.fn.shouldHaveValue = (val, msg) ->
  equal @.val(), val, msg or "#{@selectorText()} should have a value of #{val}"
  @

$.fn.shouldBe = (attr, msg) ->
  state = true
  @each ->
    state = $(@).is(attr)
    ok state, msg or "#{$(@).selectorText()} should be #{attr}"
    state
  state

$.fn.shouldNotBe = (attr, msg) ->
  state = true
  @each ->
    state = !$(@).is(attr)
    ok state, msg or "#{$(@).selectorText()} should not be #{attr}"
    state
  state

$.fn.shouldBeOnly = (attr, msg) ->
  state = true
  $set = @
  $set.each ->
    state = $(@).is(attr)
    if state
      state = !$(@).siblings().not($set).is(attr)
    ok state, msg or "#{$(@).selectorText()} should be one of the only #{attr} elements"
    state
  state

$.fn.shouldSay = (text, msg) ->
  equal @text(), text, msg or "#{text} is displayed within #{@selectorText()}"
  @

fixture =
  buildElements: ->
    $set = $()
    for el, text in elements
      if typeof text == "String"
        $set.add($("<div />").text(text))
      else
        $set.add($("<div />").append(@buildElements(text)))
    $set
  generate: (elements) ->
    @$el.append @buildElements(elements)
  get: ->
    @$ctx && @$ctx.data('stagehand')
  use: (selector) ->
    $("#qunit-fixture").children().not(selector).remove()
  select: (stage, scene) ->
    ok true, "selecting stage #{stage} scene #{scene}"
    if typeof stage == 'number'
      @get().$controls.find('> ul > li').eq(stage).find('li').eq(scene).find('a').click()
    else
      @stageControls(stage).eq(scene).find("a").click()
  stageControls: (name) ->
    @get().$controls.find("h2:contains('#{name}')").next('ul').find("li")
  stage: (name) ->
    $("#qunit-fixture [data-stage='#{name}']")
  init: (opts, $context) ->
    $context ?= $(document.body)
    @$ctx = $context.stagehand(opts)
    @$el = $("#qunit-fixture")
    @

QUnit.testDone ->
  $(document.body).data('stagehand').teardown()

module 'Base Functionality'

test 'it chains properly', ->
  deepEqual fixture.init().$ctx.hide().show(), $(document.body), '.stagehand() returns proper element'

test 'it produces a Stage object', ->
  sc = fixture.init().get()
  deepEqual sc.$el.hide().show(), $(document.body), "stagehand().data('stagehand') returns stagehand object"

test 'it appends controls to the body', ->
  sc = fixture.init().get()
  sc.$controls.shouldBe('#stagehand-controls')
  sc.$controls.parent().shouldBe($(document.body), 'controls should be appended to body')

test 'it detects siblings with `data-stage` attributes as one scene', ->
  fixture.use '.direct_siblings'
  sc = fixture.init().get()
  equal sc.$controls.find('> ul > li').length, 2, 'two scene controls built'
  sc.$controls.find('.stagehand-active').eq(0).shouldSay('1')
  equal sc.$controls.find('> ul > li').eq(0).find('li').length, 2, 'first scene control has two options'
  equal sc.$controls.find('> ul > li').eq(1).find('li').length, 1, 'second scene control has one option'

test 'it shows the first scene of each stage by default', ->
  fixture.use '.direct_siblings'
  sc = fixture.init().get()
  $('p[data-stage]').eq(0).shouldBe(':visible')
  $('p[data-stage]').eq(1).shouldNotBe(':visible')

test 'changing a stage control to a new scene changes the associated stage', ->
  fixture.use '.direct_siblings'
  sc = fixture.init().get()
  fixture.select(0, 1)
  $('p[data-stage]').eq(0).shouldNotBe(':visible')
  $('p[data-stage]').eq(1).shouldBe(':visible')

module 'Named stages and scenes'

test 'support named `data-stage` attributes', ->
  fixture.use '.named_stages'
  sc = fixture.init().get()
  sc.$controls.find("h2").eq(1).shouldSay('foo')
  fixture.select('foo', 1)
  fixture.select('bar', 2)
  fixture.select('Stage 1', 1)
  fixture.stage('foo').eq(0).shouldNotBe(':visible')
  fixture.stage('foo').eq(1).shouldBe(':visible')
  fixture.stage('bar').eq(1).shouldNotBe(':visible')
  fixture.stage('bar').eq(2).shouldBe(':visible')
  fixture.stage('Stage 1').eq(0).shouldNotBe(':visible')
  fixture.stage('Stage 1').eq(1).shouldBe(':visible')

test 'support multiple named `data-stage` attributes', ->
  fixture.use '.shared_stages'
  sc = fixture.init().get()
  equal fixture.stageControls('foo').length, 3, '3 items in foo control'
  equal fixture.stageControls('bar').length, 3, '3 items in bar control'
  equal fixture.stageControls('baz').length, 3, '3 items in baz control'
  $('.actor_1_1, .actor_2_1, .actor_3_1').shouldBeOnly(':visible')
  fixture.select('foo', 2)
  $('.actor_4').shouldBe(':visible')
  fixture.select('foo', 1)
  fixture.select('baz', 2)
  $('.actor_4').shouldNotBe(':visible')
  $('.actor_5').shouldBe(':visible')

test 'support named `data-scene` attributes', ->
  fixture.use '.named_scenes'
  sc = fixture.init().get()
  $('.actor_1_1, .actor_2_1').shouldBeOnly(':visible')
  fixture.select('foo', 1)
  fixture.select('Stage 1', 1)
  $('.actor_1_2, .actor_2_2').shouldBeOnly(':visible')

test 'support multiple named `data-scene` attributes', ->
  fixture.use '.shared_scenes'
  fixture.init()
  $('.actor_1, .actor_4').shouldBeOnly(':visible')
  fixture.select('foo', 1)
  $('.actor_2, .actor_4').shouldBeOnly(':visible')
  fixture.select('foo', 2)
  $('.actor_3').shouldBeOnly(':visible')

test 'user can use `data-default-scene` to set a specific initial scene', ->
  fixture.use '.default_scene'
  fixture.init()
  $('.actor_2').shouldBeOnly(':visible')

module 'Changing attributes'

test 'toggle classes via `data-scene-class` attribute', ->
  fixture.use '.scene_attributes'
  fixture.init()
  $('.actor_1').shouldBeOnly('.active')
  fixture.select(0, 1)
  $('.actor_2').shouldBeOnly('.active')

test 'toggle ids via `data-scene-id` attribute', ->
  fixture.use '.scene_attributes'
  fixture.init()
  $('.actor_1').shouldBeOnly('#some_id')
  fixture.select(0, 1)
  equal $("#some_id").length, 0, 'correctly does not apply an id to any element in this scene'
  fixture.select(0, 2)
  $('.actor_3').shouldBeOnly('#some_id')

test 'support toggling attributes while using multiple named `data-scene` attributes', ->
  fixture.use '.shared_scene_attributes'
  fixture.init()
  $('.actor_1, .actor_4').shouldBeOnly('.active')
  fixture.select('foo', 1)
  $('.actor_2, .actor_4').shouldBeOnly('.active')
  fixture.select('foo', 2)
  $('.actor_3').shouldBeOnly('.active')

test 'support special `data-scene` attribute of `all`', ->
  fixture.use '.keyword_all'
  sc = fixture.init().get()
  equal sc.$controls.find('li li').length, 3, 'scene control has 3 options'
  sc.$controls.find('li li').first().shouldSay('none')
  $("[class^='actor']").shouldNotBe(':visible')
  fixture.select(0, 1)
  $('.actor_1, .actor_3, .actor_4').shouldBeOnly(':visible')
  fixture.select(0, 2)
  $('.actor_2, .actor_3, .actor_4').shouldBeOnly(':visible')

test 'support special ! character to exclude scenes', ->
  fixture.use '.keyword_not'
  sc = fixture.init().get()
  equal sc.$controls.find('li li').length, 4, 'scene control has 4 options'
  sc.$controls.find('li li').first().shouldSay('none')
  fixture.select(0, 0)
  $("[class^='actor']").shouldNotBe(':visible')
  fixture.select(0, 1)
  $('.actor_1').shouldBeOnly(':visible')
  fixture.select(0, 2)
  $('.actor_2, .actor_4').shouldBeOnly(':visible')

test 'support special `data-scene` attribute of `toggle`', ->
  fixture.use '.keyword_toggle'
  sc = fixture.init().get()
  equal sc.$controls.find('li li').length, 4, 'scene control has 4 options'
  sc.$controls.find('li li')
    .first().shouldSay('toggle off')
    .next().shouldSay('toggle on')
  $("[class^='actor']").shouldNotBe(':visible')
  fixture.select(0, 1)
  $(".actor_3").shouldBeOnly(':visible')
  fixture.select(0, 2)
  $(".actor_1").shouldBeOnly(':visible')

module 'Callbacks'

test 'afterSceneChange callback', ->
  fixture.use '.shared_scenes'
  opts = {
    afterSceneChange: ($actors_on) ->
      $actors_on.addClass('changed')
  }
  $("#qunit-fixture").find('p').shouldNotBe('.changed')
  fixture.init(opts)
  $('.actor_1, .actor_4').shouldBeOnly('.changed')

