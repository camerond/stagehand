---
layout: application
---

## How will this interact with my application's JavaScript?

Ideally, it won't -- Stagehand is there to help you __decouple__ application views from static markup views. In an ideal scenario, Stagehand-enabled static views with filler content live in peaceful harmony with actual implemented application views. This is a technique we use at [Hashrocket](http://hashrocket.com) to help designers stay one step ahead of developers, so the devs always have a completed design to implement.

## That sounds like a lot to maintain.

It's not, actually. By 'one step ahead', I mean a manner of days to a couple of weeks. Stagehand helps us (the design team) respond to client needs and make UI adjustments on the fly, without slowing down the dev team or mucking with production code. If UI changes, we update the static markup, update the Stagehand interactions, and push it to a branch (if necessary).

Especially if you're working on a Backbone or Ember app (or anything else with a heavy frontend), being able to debug various interface states outside of the framework itself is a huge productivity boost.

## But I want to prototype interactions, not just states!

Hey, man, if that's what you want to do, go for it. We've tried all sorts of methods for simulating interfaces, from quick-and-dirty rapid prototyping to maintaining separate interface simulation JavaScript just for our static markup.

However, what we've found is that simulating states rather than specific interactions & animations results in less (almost zero) throwaway JS, while accomplishing 95% of what the static markup is there to do anyway. Stagehand is an effort to help us think of static markup as a form of __visual documentation__ -- and so far it's done wonders for our communication and process.
