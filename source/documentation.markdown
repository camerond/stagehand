## Preview various interface states without writing a single line of Javascript.

Stagehand helps designers (and developers) use simple static markup to describe, visualize, and debug complex interface interactions. Stagehand parses your HTML looking for specific data attributes and generates a control panel for toggling states of your page – all without requiring any Javascript.

Stagehand __isn't__ a tool for integrating with your actual app's views; it's a tool that turns static markup into living visual documentation. (Photoshop folks: think of Stagehand as Layer Comps for the browser.)

~~~html
<p data-stage data-scene='scene 1'>I'm only shown in Scene 1!</p>
<p data-stage data-scene='scene 2'>I'm only shown in Scene 2!</p>
~~~

Or, a more concrete use case:

~~~html
<div data-stage='Search Results' data-scene='initial state'>
  Search for some stuff!
</div>

<div data-stage='Search Results' data-scene='results'>
  <!-- your sweet search result markup here -->
</div>

<div data-stage='Search Results' data-scene='no results'>
  Sorry, no results, man
</div>
~~~

[view expanded example](http://camerond.github.io/stagehand/examples/1)

Designers can quickly slice designs with filler content and define various states using Stagehand, and developers can then use the Stagehand-enhanced page as a comprehensive reference when they're implementing features.

## Usage

Stagehand is dependent upon jQuery, so you'll need that. Then include [stagehand.js.coffee](https://github.com/camerond/stagehand/blob/master/source/javascripts/stagehand.js.coffee), [stagehand.sass](https://github.com/camerond/stagehand/blob/master/source/stylesheets/stagehand.sass), download and update the stylesheet URL to the [toolbar icon](https://github.com/camerond/stagehand/blob/master/source/images/stagehand_icon.png), and then just toss this in:

~~~javascript
$(document.body).stagehand()
~~~

Stagehand does the rest. You'll se a sidebar control generated in the top left of your page, and once you have stages and scenes in your markup, you'll see controls for manipulating them in there.

## Stages, scenes, and actors

### Stages

Stages are groups of elements (or, for the sake of thematic consistency, "actors"). You can either give a stage a name, or it will be auto-named ("Stage 1" and so on).

Direct siblings with the same unnamed stage attribute are grouped together into a single stage.

~~~html
<div data-stage>
  I'm part of Stage 1
</div>

<div data-stage>
  I'm part of Stage 1
</div>

<div data-stage='hammerpants'>
  I'm part of stage 'hammerpants'
</div>

<div data-stage>
  I'm part of Stage 2
</div>
~~~

[view expanded example](http://camerond.github.io/stagehand/examples/2)

### Scenes

Scenes are various states of stages. When a scene is active, any actors with that stage & scene will be shown, else they'll be hidden. Alternately, if you give an actor a `data-scene-class` or `data-scene-id` attribute, that class and/or id will be toggled instead.

Scene names are entirely optional: if you don't give an actor a `data-scene` attribute, it'll default to an integer.

~~~html
<div data-stage>
  I'm only shown when Stage 1, scene '1' is active
</div>

<div data-stage data-scene='hammerpants'>
  I'm only shown when Stage 1, scene 'hammerpants' is active
</div>

<div data-stage data-scene='hammerpants' data-scene-class='highlighted'>
  I get a class of 'highlighted' when Stage 1, scene 'hammerpants' is active
</div>
~~~

[view expanded example](http://camerond.github.io/stagehand/examples/3)

## Complexities

One stage name is a keyword: `all`. Anything with a stage name of `all` is shown in all scenes of its stage, and the Stagehand toolbar then provides an additional scene of `none` for that stage – the `none` scene toggles all actors off, including those with a scene of `all`.

~~~html
<div data-stage>
  I'm only shown when Stage 1, scene '1' is active
</div>

<div data-stage data-scene='all'>
  I'm visible in all scenes of Stage 1
</div>
~~~

You can assign multiple stages and scenes to an element, separated by commas:

~~~html
<div data-stage data-scene='stop, hammertime'>
  I'm in scene 'stop' and scene 'hammertime' of Stage 1
</div>
~~~

You can also assign multiple stages to an element, though that's a little less likely to be necessary:

~~~html
<div data-stage='hammer, pants' data-scene='all'>
  I'm in all scenes of stage 'hammer' and stage 'pants'
</div>
~~~

[view expanded example](http://camerond.github.io/stagehand/examples/4)

You can nest stages and scenes to your heart's content, it'll all work just fine.

## Callbacks

In case you need some supporting Javascript to fire, there's an afterSceneChange callback that provides you with a few useful parameters:

~~~javascript
$(document.body).stagehand({
  afterSceneChange: function($actors_on, $actors_off) {
    // $actors_on is the set of actors that just got toggled on by this scene change
    // $actors_off is the set of actors that just got toggled off by this scene change
  }
});
~~~

## Styling

If you'd prefer that the Stagehand toolbar overlay on top of your page rather than pushing everything to the right when it expands, set `overlay` to true:

~~~javascript
$(document.body).stagehand({
  overlay: true
});
~~~

## Issues / Contributing

I ([camerond](http://github.com/camerond)) am actively maintaining this project.

Naturally, submit any bug reports / feature requests on [Github](https://github.com/camerond/stagehand/issues), or just pester me at  [@camerondaigle](http://twitter.com/camerondaigle). Honestly, Stagehand does everything that I can currently imagine needing, but feel free to fork it and contribute your ideas, and I'll merge 'em if they pass muster. Be aware that there's a QUnit suite as well.

To run the suite, clone the project, bundle, run `bundle exec middleman` and visit `/test`.