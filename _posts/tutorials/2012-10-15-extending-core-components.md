---
layout    : post
title     : Extending Core Components
category  : tutorials
tags      : [styleguide, components, core, extend]
summary   : Learn how to extend core components to behave the way you want them to.
description : SUMMARY
author    : eoneill
published : false
weight    : 3
---
{% include config %}

In our last tutorial, we covered how to [create new, reusable components](/tutorials/creating-custom-components/). In this guide, we'll cover extending existing components to introduce new functionality or behave the way you want them to.

Last time we left off with this example:

{% highlight css %}
$a-blackhole: styleguide-extend-component($STYLEGUIDE_COPY_ID, (
  (in-example, (
    font-size   20px,
    color       red
  ))
), $CONFIG_THEME);
{% endhighlight %}

Let's take a minute and talk about what's going on here.

## styleguide-extend-component()

The first thing you'll notice is we're using the method [`styleguide-extend-component()`](/documentation/native/#Archetype/SassExtensions/Styleguide.html).

The first parameter this method takes is the ID of the component you wish to extend.

Second is the component structure object you wish to extend it with.

Finally there is the theme name (in most cases, passing `$CONFIG_THEME` is what you'll want).

This is all fairly straight forward. The object passed in follows the same structure as that laid out in the previous tutorial.

## Completely overhauling a component

[`styleguide-extend-component()`](/documentation/native/#Archetype/SassExtensions/Styleguide.html) is great when you want to add on minor functionality. It's not as convenient when you want to completely change the behavior of a component.

Every component that ships with Archetype also comes with an interface for to override the default. This is done by specifying a component structure into the provided variable. For example, [buttons](/components/buttons/) will extend any styles defined in `$STYLEGUIDE_BUTTONS`.

Here's an example of how to extend the native behavior of buttons:

{% highlight css %}
$STYLEGUIDE_BUTTONS: (
  (default, (
    font-style    italic,
    margin-left   20px
  )),
  (spotlight, (
    width         300px,
    nil
  ))
);

@import "archetype";
{% endhighlight %}

<span class="note">NOTE: you need to define any custom overrides _before_ you import archetype.</span>

In this example, buttons will now inherit these's behaviors in addition to the other behaviors defined by default.

If there's a conflict (e.g. font-weight is defined in both yours and the default), your styles defined here will take precedence.

This mechanism can be used to completely overhaul a component to meet your custom needs.

_Happy hacking!_