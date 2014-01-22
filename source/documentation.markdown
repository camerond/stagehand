---
layout: application
---

## Preview various interface states without writing a single line of JavaScript.

Stagehand helps designers (and developers) use simple static markup to describe, visualize, and debug complex interface interactions. Just include some simple data attributes in your HTML, and Stagehand will generate a control panel for toggling states of your page.

Stagehand __isn't__ a tool for integrating with your actual app's views; it's a tool that turns static markup into something akin to visual documentation. (Photoshop folks: think of Stagehand as Layer Comps for the browser.)

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

Designers can quickly slice designs with filler content and define various states using Stagehand, and developers can then use the Stagehand-enhanced page as a comprehensive reference when they're implementing features.

## Usage

Stagehand is dependent upon jQuery, so you'll need that. Then include the CoffeeScript & SASS (or JavaScript and CSS) files and the toolbar icon (all provided on [the Stagehand Github page](https://github.com/camerond/stagehand)) and call this method:

~~~javascript
$(document.body).stagehand()
~~~

Stagehand does the rest. You'll se a sidebar control generated in the top left of your page, and once you have stages and scenes in your markup, you'll see controls for manipulating them in there.

## Stages, scenes & actors

__Stages__ are groups of elements (or, for the sake of thematic consistency, "actors"). Actors with the same stage will be grouped together in the Stagehand toolbar as one __scene__. Stagehand will name stages & scenes for you (see [example 1](/examples/1)) or you can name them yourself (see [example 2](/examples/2)).

When a scene is active, any actors with that stage & scene will be shown, else they'll be hidden. Alternately, if you give an actor a `data-scene-class` or `data-scene-id` attribute, that class and/or id will be toggled instead -- this is shown in [example 3](/examples/3).

~~~html
<div data-stage>
  I'm an actor in stage 1, scene 1
</div>

<div data-stage='hammerpants' data-scene='hammertime'>
  I'm an actor in stage 'hammerpants', scene 'hammertime'
</div>
~~~

## Persistence

Stagehand uses sessionStorage to remember each scene's state after page refresh.

You can also add `data-default-scene` to set any scene as the first to be displayed (Stagehand will otherwise default to displaying the first scene listed):

~~~html
<div data-stage data-scene='stop'>
  I'll be hidden when the page is loaded
</div>

<div data-stage data-scene='hammertime' data-default-scene>
  I'll be shown when the page is loaded
</div>
~~~

## Complexities

There are two special stage names: `all` and `toggle`. Anything with a stage name of `all` is shown in all scenes of its stage, and anything with a stage name of `toggle` can be toggled on and off. You can nest stages & scenes, and assign multiples of either (separated by commas).

Check out [example 4](/examples/4) for more info on Stagehand's more complex interactions.

## Callbacks

In case you need some supporting JavaScript to fire, there's an afterSceneChange callback that provides you with a few useful parameters:

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