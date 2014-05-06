// Stagehand (plain JS)
// version 0.5
//
// Copyright (c) 2013 Cameron Daigle, http://camerondaigle.com
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

(function() {
  var AllScene, NoneScene, Scene, Stage, Stagehand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Stage = (function() {
    function Stage(name) {
      this.name = name;
      this.scenes = {};
      this.keyword_scenes = {};
      this.$els = $();
      this.$el = $(this.template);
      this.$el.find('h2').text(name);
      this.default_scene_idx = false;
    }

    Stage.prototype.template = "<li><h2></h2><ul></ul></li>";

    Stage.prototype.addEls = function($els) {
      return this.$els = this.$els.add($els);
    };

    Stage.prototype.initialize = function() {
      if (this.default_scene_idx != null) {
        return this.$el.find('li').eq(this.default_scene_idx).find('a').click();
      } else {
        return this.$el.find('a:first').click();
      }
    };

    Stage.prototype.parseScenes = function() {
      var idx,
        _this = this;

      idx = 0;
      return this.$els.each(function(k, v) {
        var $el, names, new_scene, scene_name, _i, _len, _ref, _results;

        $el = $(v);
        names = $el.attr('data-scene') ? $el.attr('data-scene').split(',') : void 0;
        _ref = names || [idx = idx + 1];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          scene_name = _ref[_i];
          new_scene = _this.getScene(_this.trimSceneName(scene_name)).addActor($el);
          if (!_this.default_scene_idx && $el.is('[data-default-scene]')) {
            _results.push(_this.default_scene_idx = new_scene.$el.index());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
    };

    Stage.prototype.getScene = function(name) {
      var _base;

      if (name === 'all') {
        this.prependSpecialOption('none', new NoneScene(this));
        return (_base = this.keyword_scenes).all || (_base.all = new AllScene(this));
      } else if (name === 'toggle') {
        this.prependSpecialOption('toggle on');
        this.prependSpecialOption('toggle off');
        return this.keyword_scenes['toggle on'];
      } else if (!this.scenes[name]) {
        this.scenes[name] = new Scene(this, name);
        this.$el.find('ul').append(this.scenes[name].$el);
      }
      return this.scenes[name];
    };

    Stage.prototype.prependSpecialOption = function(name, scene) {
      var s;

      s = scene || new Scene(this, name);
      if (!this.keyword_scenes[name]) {
        this.keyword_scenes[name] = s;
        return this.$el.find('ul').prepend(s.$el);
      }
    };

    Stage.prototype.trimSceneName = function(name) {
      return ('' + name).replace(/^\s?!?|\s+$/g, '');
    };

    Stage.prototype.toggleScene = function(name) {
      return (this.scenes[name] || this.keyword_scenes[name]).handleClick();
    };

    Stage.prototype.verify = function() {
      var _ref;

      return (_ref = this.$el.find('.stagehand-active').data('scene')) != null ? _ref.verify() : void 0;
    };

    return Stage;

  })();

  Scene = (function() {
    function Scene(stage, name) {
      this.stage = stage;
      this.name = name;
      this.$actors = $();
      this.$exclusions = $();
      this.$el = $(this.template);
      this.$el.data('scene', this).find('a').text(this.name);
    }

    Scene.prototype.template = "<li><a href='#'></a></li>";

    Scene.prototype.addActor = function($el) {
      var _ref;

      if (((_ref = $el.attr('data-scene')) != null ? _ref.indexOf("!" + this.name) : void 0) > -1) {
        this.$exclusions = this.$exclusions.add($el);
      } else {
        this.$actors = this.$actors.add($el);
      }
      return this;
    };

    Scene.prototype.toggleKeywordAll = function() {
      var _ref;

      return (_ref = this.stage.keyword_scenes.all) != null ? _ref.toggle(true) : void 0;
    };

    Scene.prototype.toggleOffOtherScenes = function() {
      var k, scene, _ref, _ref1, _results;

      this.$el.siblings().removeClass('stagehand-active');
      if ((_ref = this.stage.keyword_scenes['toggle on']) != null) {
        _ref.toggle(false);
      }
      _ref1 = this.stage.scenes;
      _results = [];
      for (k in _ref1) {
        scene = _ref1[k];
        _results.push(scene.name !== this.name && scene.toggle(false));
      }
      return _results;
    };

    Scene.prototype.handleClick = function() {
      this.toggleOffOtherScenes();
      this.toggleKeywordAll();
      return this.toggle(true);
    };

    Scene.prototype.toggleActors = function($actors, direction) {
      return $actors.each(function() {
        var $actor, id, klass;

        $actor = $(this);
        klass = $actor.attr('data-scene-class');
        id = $actor.attr('data-scene-id');
        if (klass) {
          $actor.toggleClass(klass, direction);
        }
        if (id) {
          $actor.attr("id", direction ? id : '');
        }
        if (!id && !klass) {
          return $actor.toggle(direction);
        }
      });
    };

    Scene.prototype.toggle = function(direction) {
      this.$el.toggleClass('stagehand-active', direction);
      if (direction) {
        this.toggleActors(this.$exclusions, false);
      }
      return this.toggleActors(this.$actors.not(this.$exclusions), direction);
    };

    Scene.prototype.verify = function() {
      this.toggleKeywordAll();
      return this.toggle(true);
    };

    return Scene;

  })();

  AllScene = (function(_super) {
    __extends(AllScene, _super);

    function AllScene(stage) {
      this.stage = stage;
      AllScene.__super__.constructor.call(this, this.stage, 'all');
    }

    AllScene.$exclusions = $.noop();

    return AllScene;

  })(Scene);

  NoneScene = (function(_super) {
    __extends(NoneScene, _super);

    function NoneScene(stage) {
      this.stage = stage;
      NoneScene.__super__.constructor.call(this, this.stage, 'none');
    }

    NoneScene.prototype.toggleKeywordAll = function() {
      return this.stage.keyword_scenes.all.toggle(false);
    };

    NoneScene.prototype.verify = function() {
      return this.toggle(true);
    };

    return NoneScene;

  })(Scene);

  Stagehand = {
    afterSceneChange: $.noop,
    template: "<section id='stagehand-controls'><h1>Stagehand</h1><ul></ul></section>",
    template_toggle: "<a href='#' class='stagehand-toggle'></a>",
    stages: {},
    addStage: function(name) {
      name = name.replace(/^\s+|\s+$/g, '');
      if (!this.stages[name]) {
        this.stages[name] = new Stage(name);
        this.$controls.find('> ul').append(this.stages[name].$el);
      }
      return this.stages[name];
    },
    changeScene: function(e) {
      var name, scene, stage, _ref;

      scene = $(e.target).closest('li').data('scene');
      scene.stage.toggleScene(scene.name);
      _ref = this.stages;
      for (name in _ref) {
        stage = _ref[name];
        stage.verify();
      }
      this.afterSceneChange(scene.$actors);
      return this.saveState();
    },
    parseAnonymousStages: function() {
      var $actor, $anons, $stage, idx, _results;

      $anons = this.$stage_cache.filter('[data-stage=""]');
      this.$stage_cache = this.$stage_cache.not($anons);
      idx = 1;
      _results = [];
      while ($anons.length) {
        $actor = $anons.eq(0);
        $stage = $actor.add($actor.nextUntil("[data-stage!='']"));
        $stage = $stage.add($actor.prevUntil("[data-stage!='']"));
        this.addStage("Stage " + idx).addEls($stage);
        $anons = $anons.not($stage);
        _results.push(idx = idx + 1);
      }
      return _results;
    },
    parseNamedStages: function() {
      var _this = this;

      return this.$stage_cache.each(function(k, v) {
        var $actor, stage_name, _i, _len, _ref, _results;

        $actor = $(v);
        _ref = $actor.attr('data-stage').split(',');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          stage_name = _ref[_i];
          _results.push(_this.addStage(stage_name).addEls($actor));
        }
        return _results;
      });
    },
    toggleControls: function() {
      $(document.body).toggleClass('stagehand-active');
      this.saveState();
      return false;
    },
    bindEvents: function() {
      this.$controls.on('click.stagehand', 'a.stagehand-toggle', $.proxy(this.toggleControls, this));
      return this.$controls.on('click.stagehand', 'ul a', $.proxy(this.changeScene, this));
    },
    teardown: function() {
      this.$controls.remove();
      this.$el.removeData('stagehand');
      sessionStorage.setItem("stagehand-scenes", false);
      return sessionStorage.setItem("stagehand-toggle", false);
    },
    saveState: function() {
      var $active, name, stage, stages, _ref;

      stages = {};
      _ref = this.stages;
      for (name in _ref) {
        stage = _ref[name];
        $active = stage.$el.find('.stagehand-active');
        if ($active.length) {
          stages[name] = $active.index();
        }
      }
      sessionStorage.setItem("stagehand-scenes", JSON.stringify(stages));
      return sessionStorage.setItem("stagehand-toggle", $(document.body).is(".stagehand-active"));
    },
    loadState: function() {
      var idx, stage_name, _ref, _ref1;

      _ref = JSON.parse(sessionStorage.getItem("stagehand-scenes"));
      for (stage_name in _ref) {
        idx = _ref[stage_name];
        if ((_ref1 = this.stages[stage_name]) != null) {
          _ref1.default_scene_idx = idx;
        }
      }
      if (sessionStorage.getItem('stagehand-toggle') === "true") {
        return this.toggleControls();
      }
    },
    init: function() {
      var name, stage, _ref;

      this.$controls = $(this.template).appendTo($(document.body));
      this.$controls.append($(this.template_toggle));
      this.$stage_cache = $('[data-stage]');
      this.parseAnonymousStages();
      this.parseNamedStages();
      this.bindEvents();
      this.loadState();
      _ref = this.stages;
      for (name in _ref) {
        stage = _ref[name];
        stage.parseScenes();
        stage.initialize();
      }
      return this.$el;
    }
  };

  $.fn.stagehand = function(opts) {
    var $els, method;

    $els = this;
    method = $.isPlainObject(opts) || !opts ? '' : opts;
    $els.each(function() {
      var plugin_instance;

      plugin_instance = $.extend(true, {
        $el: $(this)
      }, Stagehand, opts);
      $(this).data('stagehand', plugin_instance);
      return plugin_instance.init();
    });
    return $els;
  };

}).call(this);
