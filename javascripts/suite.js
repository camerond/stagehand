(function() {
  var $, fixture;

  $ = jQuery;

  $.fn.selectorText = function() {
    var selector, text;

    selector = "%" + (this[0].tagName.toLowerCase());
    this.attr('id') && (selector += "#" + (this.attr('id')));
    this.attr('class') && (selector += "." + (this.attr('class')));
    text = this.text().length > 30 ? "" + (this.text().slice(0, 30)) + "..." : this.text();
    text && (selector = selector + (" with text of '" + text + "'"));
    return selector;
  };

  $.fn.shouldHaveValue = function(val, msg) {
    equal(this.val(), val, msg || ("" + (this.selectorText()) + " should have a value of " + val));
    return this;
  };

  $.fn.shouldBe = function(attr, msg) {
    var state;

    state = true;
    this.each(function() {
      state = $(this).is(attr);
      ok(state, msg || ("" + ($(this).selectorText()) + " should be " + attr));
      return state;
    });
    return state;
  };

  $.fn.shouldNotBe = function(attr, msg) {
    var state;

    state = true;
    this.each(function() {
      state = !$(this).is(attr);
      ok(state, msg || ("" + ($(this).selectorText()) + " should not be " + attr));
      return state;
    });
    return state;
  };

  $.fn.shouldBeOnly = function(attr, msg) {
    var $set, state;

    state = true;
    $set = this;
    $set.each(function() {
      state = $(this).is(attr);
      if (state) {
        state = !$(this).siblings().not($set).is(attr);
      }
      ok(state, msg || ("" + ($(this).selectorText()) + " should be one of the only " + attr + " elements"));
      return state;
    });
    return state;
  };

  $.fn.shouldSay = function(text, msg) {
    equal(this.text(), text, msg || ("" + text + " is displayed within " + (this.selectorText())));
    return this;
  };

  fixture = {
    buildElements: function() {
      var $set, el, text, _i, _len;

      $set = $();
      for (text = _i = 0, _len = elements.length; _i < _len; text = ++_i) {
        el = elements[text];
        if (typeof text === "String") {
          $set.add($("<div />").text(text));
        } else {
          $set.add($("<div />").append(this.buildElements(text)));
        }
      }
      return $set;
    },
    generate: function(elements) {
      return this.$el.append(this.buildElements(elements));
    },
    get: function() {
      return this.$ctx && this.$ctx.data('stagehand');
    },
    use: function(selector) {
      return $("#qunit-fixture").children().not(selector).remove();
    },
    select: function(stage, scene) {
      ok(true, "selecting stage " + stage + " scene " + scene);
      if (typeof stage === 'number') {
        return this.get().$controls.find('> ul > li').eq(stage).find('li').eq(scene).find('a').click();
      } else {
        return this.stageControls(stage).eq(scene).find("a").click();
      }
    },
    stageControls: function(name) {
      return this.get().$controls.find("h2:contains('" + name + "')").next('ul').find("li");
    },
    stage: function(name) {
      return $("#qunit-fixture [data-stage='" + name + "']");
    },
    init: function(opts, $context) {
      if ($context == null) {
        $context = $(document.body);
      }
      this.$ctx = $context.stagehand(opts);
      this.$el = $("#qunit-fixture");
      return this;
    }
  };

  QUnit.testDone(function() {
    return $(document.body).data('stagehand').teardown();
  });

  module('Base Functionality');

  test('it chains properly', function() {
    return deepEqual(fixture.init().$ctx.hide().show(), $(document.body), '.stagehand() returns proper element');
  });

  test('it produces a Stage object', function() {
    var sc;

    sc = fixture.init().get();
    return deepEqual(sc.$el.hide().show(), $(document.body), "stagehand().data('stagehand') returns stagehand object");
  });

  test('it appends controls to the body', function() {
    var sc;

    sc = fixture.init().get();
    sc.$controls.shouldBe('#stagehand-controls');
    return sc.$controls.parent().shouldBe($(document.body), 'controls should be appended to body');
  });

  test('it detects siblings with `data-stage` attributes as one scene', function() {
    var sc;

    fixture.use('.direct_siblings');
    sc = fixture.init().get();
    equal(sc.$controls.find('> ul > li').length, 2, 'two scene controls built');
    sc.$controls.find('.stagehand-active').eq(0).shouldSay('1');
    equal(sc.$controls.find('> ul > li').eq(0).find('li').length, 2, 'first scene control has two options');
    return equal(sc.$controls.find('> ul > li').eq(1).find('li').length, 1, 'second scene control has one option');
  });

  test('it shows the first scene of each stage by default', function() {
    var sc;

    fixture.use('.direct_siblings');
    sc = fixture.init().get();
    $('p[data-stage]').eq(0).shouldBe(':visible');
    return $('p[data-stage]').eq(1).shouldNotBe(':visible');
  });

  test('changing a stage control to a new scene changes the associated stage', function() {
    var sc;

    fixture.use('.direct_siblings');
    sc = fixture.init().get();
    fixture.select(0, 1);
    $('p[data-stage]').eq(0).shouldNotBe(':visible');
    return $('p[data-stage]').eq(1).shouldBe(':visible');
  });

  module('Named stages and scenes');

  test('support named `data-stage` attributes', function() {
    var sc;

    fixture.use('.named_stages');
    sc = fixture.init().get();
    sc.$controls.find("h2").eq(1).shouldSay('foo');
    fixture.select('foo', 1);
    fixture.select('bar', 2);
    fixture.select('Stage 1', 1);
    fixture.stage('foo').eq(0).shouldNotBe(':visible');
    fixture.stage('foo').eq(1).shouldBe(':visible');
    fixture.stage('bar').eq(1).shouldNotBe(':visible');
    fixture.stage('bar').eq(2).shouldBe(':visible');
    fixture.stage('Stage 1').eq(0).shouldNotBe(':visible');
    return fixture.stage('Stage 1').eq(1).shouldBe(':visible');
  });

  test('support multiple named `data-stage` attributes', function() {
    var sc;

    fixture.use('.shared_stages');
    sc = fixture.init().get();
    equal(fixture.stageControls('foo').length, 3, '3 items in foo control');
    equal(fixture.stageControls('bar').length, 3, '3 items in bar control');
    equal(fixture.stageControls('baz').length, 3, '3 items in baz control');
    $('.actor_1_1, .actor_2_1, .actor_3_1').shouldBeOnly(':visible');
    fixture.select('foo', 2);
    $('.actor_4').shouldBe(':visible');
    fixture.select('foo', 1);
    fixture.select('baz', 2);
    $('.actor_4').shouldNotBe(':visible');
    return $('.actor_5').shouldBe(':visible');
  });

  test('support named `data-scene` attributes', function() {
    var sc;

    fixture.use('.named_scenes');
    sc = fixture.init().get();
    $('.actor_1_1, .actor_2_1').shouldBeOnly(':visible');
    fixture.select('foo', 1);
    fixture.select('Stage 1', 1);
    return $('.actor_1_2, .actor_2_2').shouldBeOnly(':visible');
  });

  test('support multiple named `data-scene` attributes', function() {
    fixture.use('.shared_scenes');
    fixture.init();
    $('.actor_1, .actor_4').shouldBeOnly(':visible');
    fixture.select('foo', 1);
    $('.actor_2, .actor_4').shouldBeOnly(':visible');
    fixture.select('foo', 2);
    return $('.actor_3').shouldBeOnly(':visible');
  });

  test('user can use `data-default-scene` to set a specific initial scene', function() {
    fixture.use('.default_scene');
    fixture.init();
    return $('.actor_2').shouldBeOnly(':visible');
  });

  module('Changing attributes');

  test('toggle classes via `data-scene-class` attribute', function() {
    fixture.use('.scene_attributes');
    fixture.init();
    $('.actor_1').shouldBeOnly('.active');
    fixture.select(0, 1);
    return $('.actor_2').shouldBeOnly('.active');
  });

  test('toggle ids via `data-scene-id` attribute', function() {
    fixture.use('.scene_attributes');
    fixture.init();
    $('.actor_1').shouldBeOnly('#some_id');
    fixture.select(0, 1);
    equal($("#some_id").length, 0, 'correctly does not apply an id to any element in this scene');
    fixture.select(0, 2);
    return $('.actor_3').shouldBeOnly('#some_id');
  });

  test('support toggling attributes while using multiple named `data-scene` attributes', function() {
    fixture.use('.shared_scene_attributes');
    fixture.init();
    $('.actor_1, .actor_4').shouldBeOnly('.active');
    fixture.select('foo', 1);
    $('.actor_2, .actor_4').shouldBeOnly('.active');
    fixture.select('foo', 2);
    return $('.actor_3').shouldBeOnly('.active');
  });

  test('support special `data-scene` attribute of `all`', function() {
    var sc;

    fixture.use('.keyword_all');
    sc = fixture.init().get();
    equal(sc.$controls.find('li li').length, 3, 'scene control has 3 options');
    sc.$controls.find('li li').first().shouldSay('none');
    $("[class^='actor']").shouldNotBe(':visible');
    fixture.select(0, 1);
    $('.actor_1, .actor_3, .actor_4').shouldBeOnly(':visible');
    fixture.select(0, 2);
    return $('.actor_2, .actor_3, .actor_4').shouldBeOnly(':visible');
  });

  test('switching to `none` scene should not override shared `all` actors', function() {
    fixture.use('.keyword_shared_all');
    fixture.init();
    $("[class^='actor']").shouldNotBe(':visible');
    fixture.select(0, 1);
    $('.actor_1, .actor_3').shouldBeOnly(':visible');
    fixture.select(1, 1);
    $('.actor_1, .actor_2, .actor_3').shouldBeOnly(':visible');
    fixture.select(0, 0);
    return $('.actor_2, .actor_3').shouldBeOnly(':visible');
  });

  test('support special ! character to exclude scenes', function() {
    var sc;

    fixture.use('.keyword_not');
    sc = fixture.init().get();
    equal(sc.$controls.find('li li').length, 3, 'scene control has 3 options');
    $('.actor_2, .actor_4').shouldBeOnly(':visible');
    fixture.select(0, 1);
    $('.actor_3, .actor_4').shouldBeOnly(':visible');
    fixture.select(0, 2);
    return $('.actor_1').shouldBeOnly(':visible');
  });

  test('support special ! character to exclude scenes, with explicit "all"', function() {
    var sc;

    fixture.use('.keyword_all_not');
    sc = fixture.init().get();
    equal(sc.$controls.find('li li').length, 4, 'scene control has 4 options');
    sc.$controls.find('li li').first().shouldSay('none');
    fixture.select(0, 0);
    $("[class^='actor']").shouldNotBe(':visible');
    fixture.select(0, 1);
    $('.actor_3, .actor_4, .actor_5').shouldBeOnly(':visible');
    fixture.select(0, 2);
    return $('.actor_1').shouldBeOnly(':visible');
  });

  test('support special `data-scene` attribute of `toggle`', function() {
    var sc;

    fixture.use('.keyword_toggle');
    sc = fixture.init().get();
    equal(sc.$controls.find('li li').length, 4, 'scene control has 4 options');
    sc.$controls.find('li li').first().shouldSay('toggle off').next().shouldSay('toggle on');
    $("[class^='actor']").shouldNotBe(':visible');
    fixture.select(0, 1);
    $(".actor_3").shouldBeOnly(':visible');
    fixture.select(0, 2);
    return $(".actor_1").shouldBeOnly(':visible');
  });

  module('Callbacks');

  test('afterSceneChange callback', function() {
    var opts;

    fixture.use('.shared_scenes');
    opts = {
      afterSceneChange: function($actors_on) {
        return $actors_on.addClass('changed');
      }
    };
    $("#qunit-fixture").find('p').shouldNotBe('.changed');
    fixture.init(opts);
    return $('.actor_1, .actor_4').shouldBeOnly('.changed');
  });

}).call(this);
