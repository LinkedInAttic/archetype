---
layout    : post
title     : Organizing Your Framework Imports
category  : tutorials
tags      : [archetype, structure, extend]
summary   : It's fun to be a rebel. Learn how to shim in your own functionality into Archetype and other frameworks
description : SUMMARY
author    : eoneill
published : true
weight    : 8
---
{% include config %}

This tutorial is nothing special, but we'll go over some organization patterns we've learned in our experience and how to coax these frameworks to do your bidding.

## Directory Structure

Let's start with the directory structure:

{% highlight bash %}
scss/
|   _archetype.scss
|   _compass.scss
|-- apps/
|   \   main.scss
|-- lib/
|   |   _archetype.scss
|   |   _compass.scss
|   |-- archetype/
|   |   |   _config.scss
|   |   |   _overrides.scss
|   |   \   _shim.scss
|   \-- compass/
|       |   _config.scss
|       |   _overrides.scss
|       \   _shim.scss
\-- themes/
    |   _awesome_sauce.scss
    \-- awesome_sauce
        |   _config.scss
        |   _theme.scss
        |   _primitives.scss
        |   _components.scss
        |-- primitives/
        \-- components/
{% endhighlight %}

## Import Chain

Now let's look at what we put in those files. Say, we want to overload the way the Compass `bang-hack()` mixin behaves.

<span class="note">`[scss/_compass.scss]`</span>
{% highlight css %}
@import "lib/compass";
{% endhighlight %}

<span class="note">`[scss/lib/_compass.scss]`</span>
{% highlight css %}
@import "compass/config";
@import "compass/shim";
@import "compass/overrides";
{% endhighlight %}

<span class="note">`[scss/lib/compass/_config.scss]`</span>
{% highlight css %}
// define any compass configs here
{% endhighlight %}

<span class="note">`[scss/lib/compass/_shim.scss]`</span>
{% highlight css %}
// import any compass modules you want here
@import "compass/css3";
{% endhighlight %}

<span class="note">`[scss/lib/compass/_overrides.scss]`</span>
{% highlight css %}
// override the bang-hack mixin to instead use _ hack
@mixin bang-hack($property, $value, $ie6-value) {
  @if $legacy-support-for-ie6 {
    #{$property}: #{$value};
    _#{$property}: #{$ie6-value};
  }
}
{% endhighlight %}

Pheww! Still with me? Now with all that setup, I can `@import "compass"` in my application and get all my shared configs as well as our custom overrides to compass.

We can use this same logic for Archetype, especially when creating custom themes.