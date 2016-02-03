# 0.6

- change initialization to global `Stagehand.init()` call
- add `Stagehand.refresh()`

# 0.5.1

- fix buggy behavior of `!` and bake it into native Scene class more explicitly
- `!` is no longer depended on an actor also having the `all` scene assigned

# 0.5

- far-reaching rewrite behind the scenes, more extensible and easy to read now
- add support for `!` to exclude specific scenes

# 0.4.3

- support default scenes through `stagehand-default-scene` attribute

# 0.4.2

- fix bug where SessionStorage didn't restore `toggle` scenes
- formatting adjustments to style panel for `toggle on` and `toggle off` options to fit on one line

# 0.4.1

- support `toggle` scene keyword

# 0.4

- add sessionStorage for panel & active stage state

# 0.3

- add readme, changelog
- remove context element from afterSceneChange callback arguments
- add mobile styles to sidebar
- add overlay toggle option for sidebar

# 0.2.3

- remove `stages` array from Stagehand object; all unnamed stages are now auto-named
- allow multiple stages on one element

# 0.2.2

- support `all` scene keyword

# 0.2.1

- add afterSceneChange callback

# 0.2

- add class and id toggling
- add toolbar styles

# pre-0.2

- these were dark times
