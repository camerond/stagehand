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
    teardown: function() {
      this.$controls.remove();
      return this.$el.removeData(this.name);
    },
    buildControls: function() {
      var k, v, _ref, _results;

      if (this.$controls) {
        this.$controls.empty();
      } else {
        this.$controls = $(this.templates.controls).append($(this.templates.toggle));
        $(document.body).append(this.$controls).addClass('.stagehand-enabled');
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
      this.prependNoneOption($li, $stage);
      $li.find('a').data('$stage', $stage);
      this.stage_controls.push($li);
      return this.$controls.find("> ul").append($li);
    },
    prependNoneOption: function($li, $stage) {
      var $button;

      if ($stage.filter("[data-scene='all']").length) {
        return $button = $(this.templates.control_button).prependTo($li.find('ul')).find('a').text('none');
      }
    },
    buildOrAppendControlButton: function($actor, $control, idx) {
      var $button, i, scene, scenes, _i, _len;

      scenes = $actor.attr('data-scene') ? $actor.attr('data-scene').split(',') : ["" + (idx + 1)];
      for (i = _i = 0, _len = scenes.length; _i < _len; i = ++_i) {
        scene = scenes[i];
        if (scene === 'all') {
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
      if ($a.text() === 'none') {
        $actors_on = $();
        $actors_off = $a.data('$stage');
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
      return false;
    },
    bindEvents: function() {
      this.$controls.on('click.stagehand', 'ul a', $.proxy(this.changeScene, this));
      return this.$controls.on('click.stagehand', 'a.stagehand-toggle', this.toggleControls);
    },
    init: function() {
      this.detectScenes();
      this.buildControls();
      this.bindEvents();
      this.overlay && $(document.body).toggleClass('stagehand-overlay');
      $.each(this.stage_controls, function() {
        return $(this).find('a').eq(0).trigger('click.stagehand');
      });
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
