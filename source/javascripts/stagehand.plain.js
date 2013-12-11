// Stagehand (plain JS)
// version 0.4.2
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
  var Stagehand;

  Stagehand = {
    name: 'stagehand',
    afterSceneChange: $.noop(),
    stages: {},
    stage_controls: [],
    templates: {
      controls: "<section id='stagehand-controls'><h1>Stagehand</h1><ul></ul></section>",
      control: "<li><h2></h2><ul></ul></li>",
      control_button: "<li><a href='#'></a></li>",
      toggle: "<a href='#' class='stagehand-toggle'></a>"
    },
    saveState: function() {
      var $active, $control, scenes, _i, _len, _ref;

      scenes = {};
      _ref = this.stage_controls;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        $control = _ref[_i];
        $active = $control.find('.stagehand-active');
        if ($active.length) {
          scenes[$control.attr('data-stage')] = $active.attr('data-scene-control');
        }
      }
      sessionStorage.setItem("stagehand-scenes", JSON.stringify(scenes));
      return sessionStorage.setItem("stagehand-toggle", $("body").is(".stagehand-active"));
    },
    loadState: function() {
      var scene, stage, _ref;

      $(document.body).toggleClass('stagehand-active', sessionStorage.getItem('stagehand-toggle') === 'true');
      _ref = JSON.parse(sessionStorage.getItem("stagehand-scenes"));
      for (stage in _ref) {
        scene = _ref[stage];
        this.$controls.find("[data-stage='" + stage + "'] [data-scene-control='" + scene + "']").trigger('click.stagehand');
      }
      return this.$controls.find("[data-stage]").each(function() {
        if (!$(this).find('.stagehand-active').length) {
          return $(this).find('a').eq(0).trigger('click.stagehand');
        }
      });
    },
    teardown: function() {
      this.$controls.remove();
      this.$el.removeData(this.name);
      sessionStorage.setItem("stagehand-scenes", false);
      return sessionStorage.setItem("stagehand-toggle", false);
    },
    buildControls: function() {
      var k, v, _ref, _results;

      if (this.$controls) {
        this.$controls.empty();
      } else {
        this.$controls = $(this.templates.controls).append($(this.templates.toggle));
        $(document.body).append(this.$controls);
      }
      _ref = this.stages;
      _results = [];
      for (k in _ref) {
        v = _ref[k];
        _results.push(this.buildStageControl(k, v));
      }
      return _results;
    },
    buildStageControl: function(name, $stage) {
      var $li, s;

      s = this;
      $li = $(this.templates.control);
      $li.attr('data-stage', name).find('h2').text(name);
      $stage.each(function(idx) {
        var $button;

        return $button = s.buildOrAppendControlButton($(this), $li, idx);
      });
      this.prependSpecialOptions($li, $stage);
      $li.find('a').data('$stage', $stage);
      this.stage_controls.push($li);
      return this.$controls.find("> ul").append($li);
    },
    prependSpecialOptions: function($li, $stage) {
      var $button, special, txt, _i, _len, _results;

      special = [];
      if ($stage.filter("[data-scene='all']").length) {
        special.push('none');
      }
      if ($stage.filter("[data-scene='toggle']").length) {
        special.push('toggle on');
        special.push('toggle off');
      }
      _results = [];
      for (_i = 0, _len = special.length; _i < _len; _i++) {
        txt = special[_i];
        _results.push($button = $(this.templates.control_button).prependTo($li.find('ul')).find('a').text(txt).attr('data-scene-control', "special-" + (txt.replace(' ', '-'))));
      }
      return _results;
    },
    buildOrAppendControlButton: function($actor, $control, idx) {
      var $button, i, scene, scenes, _i, _len;

      scenes = $actor.attr('data-scene') ? $actor.attr('data-scene').split(',') : ["" + (idx + 1)];
      for (i = _i = 0, _len = scenes.length; _i < _len; i = ++_i) {
        scene = scenes[i];
        if (scene === 'all' || scene === 'toggle') {
          return;
        }
        scene = scene.replace(/^\s+|\s+$/g, '');
        $button = $control.find("[data-scene-control='" + scene + "']");
        if ($button.length) {
          $button.data('$actor', $button.data('$actor').add($actor));
        } else {
          $button = $(this.templates.control_button).appendTo($control.find('ul')).find('a').attr('data-scene-control', scene).data('$actor', $actor).text(scene);
        }
      }
      return $button;
    },
    changeScene: function(e) {
      var $a, $actors_off, $actors_on, s;

      s = this;
      $a = $(e.target);
      $actors_on = $actors_off = $();
      if ($a.is("[data-scene-control^='special']")) {
        switch ($a.text()) {
          case 'none':
            $actors_off = $a.data('$stage');
            break;
          case 'toggle off':
            $actors_off = $a.data('$stage').filter("[data-scene='toggle']");
            break;
          case 'toggle on':
            $actors_on = $a.data('$stage').filter("[data-scene='toggle']");
        }
      } else {
        $actors_on = $a.data('$actor').add($a.data('$stage').filter("[data-scene='all']"));
        $actors_off = $a.data('$stage').not($actors_on);
      }
      $a.closest('ul').find('a').removeClass('stagehand-active');
      $a.addClass('stagehand-active');
      $actors_off.each(function() {
        return s.toggleActor($(this), false);
      });
      $actors_on.each(function() {
        return s.toggleActor($(this), true);
      });
      this.afterSceneChange && this.afterSceneChange($actors_on, $actors_off);
      this.saveState();
      return false;
    },
    toggleActor: function($actor, direction) {
      var id, klass;

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
    },
    detectNamedStages: function() {
      var $actor, $actor_cache, stage_name, _i, _len, _ref, _results;

      $actor_cache = $.extend(this.$actor_elements, {}).filter('[data-stage]').filter("[data-stage!='']");
      _results = [];
      while ($actor_cache.length) {
        $actor = $actor_cache.eq(0);
        _ref = $actor.attr('data-stage').split(',');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          stage_name = _ref[_i];
          stage_name = stage_name.replace(/^\s+|\s+$/g, '');
          if (this.stages[stage_name]) {
            this.stages[stage_name] = this.stages[stage_name].add($actor);
          } else {
            this.stages[stage_name] = $actor;
          }
        }
        this.$actor_elements = this.$actor_elements.not($actor);
        _results.push($actor_cache = $actor_cache.not($actor));
      }
      return _results;
    },
    detectAnonymousStages: function() {
      var $actor, $actor_cache, $stage, i, _results;

      $actor_cache = $.extend(this.$actor_elements, {});
      i = 1;
      _results = [];
      while ($actor_cache.length) {
        $actor = $actor_cache.eq(0);
        $stage = $actor.add($actor.nextUntil("[data-stage!='']"));
        $stage = $stage.add($actor.prevUntil("[data-stage!='']"));
        this.stages["Stage " + i] = $stage;
        $actor_cache = $actor_cache.not($stage);
        _results.push(i = i + 1);
      }
      return _results;
    },
    detectScenes: function() {
      this.$actor_elements = this.$el.find('[data-stage]');
      this.detectNamedStages();
      return this.detectAnonymousStages();
    },
    toggleControls: function() {
      $(document.body).toggleClass('stagehand-active');
      this.saveState();
      return false;
    },
    bindEvents: function() {
      this.$controls.on('click.stagehand', 'ul a', $.proxy(this.changeScene, this));
      return this.$controls.on('click.stagehand', 'a.stagehand-toggle', $.proxy(this.toggleControls, this));
    },
    init: function() {
      this.detectScenes();
      this.buildControls();
      this.bindEvents();
      this.overlay && $(document.body).toggleClass('stagehand-overlay');
      this.loadState();
      return this.$el;
    }
  };

  $.fn[Stagehand.name] = function(opts) {
    var $els, method;

    $els = this;
    method = $.isPlainObject(opts) || !opts ? '' : opts;
    if (method && Stagehand[method]) {
      Stagehand[method].apply($els, Array.prototype.slice.call(arguments, 1));
    } else if (!method) {
      $els.each(function() {
        var plugin_instance;

        plugin_instance = $.extend(true, {
          $el: $(this)
        }, Stagehand, opts);
        $(this).data(Stagehand.name, plugin_instance);
        return plugin_instance.init();
      });
    } else {
      $.error('Method #{method} does not exist on jQuery. #{Stagehand.name}');
    }
    return $els;
  };

}).call(this);