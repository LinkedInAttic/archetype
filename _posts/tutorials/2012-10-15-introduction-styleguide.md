---
layout    : post
title     : An Introduction to styleguide()
category  : tutorials
tags      : [intro, styleguide]
summary   : Learn how Archetype and styleguide() will transform the way designers and developers build complex, scalable, web sites.
description : SUMMARY
author    : eoneill
published : false
weight    : 1
---
{% include config %}

## Design as a Language

Archetype changes the way we discuss design and development as a profession. A common language ensures developers and designers can communicate ideas in a consistent manner. The goal of Archetype is to provide a semantic design language that isn't bound to your HTML markup.

Annotations of a mockup translate directly to a collection of identifiers, modifiers, and contexts. Imagine you're handed a mock with notes like "_this is a large headline_", "_this is a punchcut_", and "_this is a small spotlight button_". Turning these into CSS is now as easy as:

{% highlight css %}
@include styleguide(large headline)
@include styleguide(punchcut)
@include styleguide(small spotlight button in a punchcut)
{% endhighlight %}

### Identifiers

Identifiers are the various objects and components in a layout. They represent different "things", from Containers to Copy to Buttons. When marking up a design, we use the identifiers to discuss the design in concepts instead of pixel measurements and hex colors.

{% highlight css %}
@include styleguide(... headline)
@include styleguide(punchcut)
@include styleguide(... button ...)
{% endhighlight %}

### Modifiers

Modifiers describe variants and decorations of the identifiers. This can include sizes (small, medium, large), types (primary, secondary), order (first, last), and many other variants.

{% highlight css %}
@include styleguide(large headline)
@include styleguide(small spotlight button ...)
{% endhighlight %}

### Contexts

Contexts describe the parent container an element is inside of. Containers can describe textures, background colors, and various other aspects. By specifying an element's context, the element will automatically adjust to look it's sharpest.

{% highlight css %}
@include styleguide(small spotlight button in a punchcut)
{% endhighlight %}

### Explore the styleguide

Explore [the available components](/components/) to see some of the things you can do with `styleguide`.
