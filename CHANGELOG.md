# Changelog

## 0.0.1

- initial public release

## 0.0.1.pre.3 (pre-released)

### New Features:

- added `styleguide-component-exists()` method to check if a component/extension has already been registered in the theme
- added `memoize` compiler configuration to allow enabling/disabling the internal styleguide memoizer
- `glyph-icon()` can now take `false` as an icon name and not output anything
- added `unstyled-button()` method to remove default styling from a `<button>` element
- added `prefixed-tag()` method for consistency when generating tag names
- added Chinese font stacks
- added wildcard support to `locale()` function (e.g. `locale(en_ ja_JP _DE)`)

### Resolved Issues:

- quotes on strings passed to `associative()` weren't being stripped correctly
- fixed some minor glyph issues
- out-of-order CSS issues in Ruby 1.8.7 are fixed using `Hashery::OrderedHash`

### Tests:

- added test case for fallback CSS properties
- added test case for generating loading spinner keyframe animations
- updated test cases for minor changes

## 0.0.1.pre.2 (unreleased)

### New Features:

- added HTML5 Boilerplate reset
- updated normalize to 2.0.1
- added support for selective states in `styleguide` calls (e.g. styleguide(large primary button, $state: disabled))
- added support for `drop` and `styleguide` keywords in components
  - `drop` allows you to drop previously defined styles within a component definition (e.g. if you need to remove defaults)
  - `styleguide` in a component definition will insert the derived styles from a styleguide() call. this allows you to share styles between components
- added `styleguide-diff()` method
- added `ie-pseudo()` methods to support dynamically generating pseudo :before and :after elements (using expressions)
- added `stroke()` mixin to create a stroke line around text (or font icon)
- added `hide-element()` mixin to hide elements from screen but keep them screen-reader accessible
- added basic support for fallback CSS values (e.g. border: red; border: rgba(255,0,0, 0.8);)
- added `$CONFIG_STATE_MAPPINGS` to simplify the mapping between state names and selectors

### Major Changes:

- loading spinners now use CSS3 animations and require some integration work
- updated default vertical/horizontal spacing to 5px
- `list-extend()` is now `associative-merge()`

### Resolved Issues:

- nested inheritance would get corrupted (due to a volatile context being passed along)
- `$exclude` in `to-styles` wasn't taking a list of keys cleanly
- `font-family()` and `lang()` weren't respecting locale aliases
- fixed thread safety issues

### Documentation:

- updated README to be a bit friendlier
- added CONTRIBUTING
- added RDoc documentation to source

## 0.0.1.pre.1 (unreleased)

### New Features:

- `styleguide-add-component()`, `styleguide-extend-component()`, and `styleguide()` now take a `$theme` parameter
- `$CONFIG_THEME` can change the global theme
- `$CONFIG_STYLEGUIDE_DISABLE_SPRITES` will prevent styleguide sprites from being generated if set to `true`
- theme components are cached
- `styleguide()` calls are memoized

### Major Changes:

- `filter()` mixin is now `ie-filter()` to prevent conflicts with Compass' `filter()` mixin
- Compass overrides are no longer loaded as Archetype core

### Resolved Issues:

- no known issues to resolve

### Documentation:

- added README
