---
layout    : post
title     : Creating Custom Components
category  : tutorials
tags      : [intro, styleguide, components, extend, ]
summary   : In this guide, we'll cover how components work and introduce you to creating your own reusable components.
description : SUMMARY
author    : eoneill
published : true
weight    : 2
---
{% include config %}

## The inner workings

The [styleguide system](/tutorials/introduction-styleguide/) uses a combination of primitives and components to define a set of robust, reusable styles.

### Primitives

Primitives are simple, configurable values like colors, fonts, and background images. See the [Archetype core primitives]({{ GIT_PATH }}/tree/master/stylesheets/archetype/styleguide/primitives) for some examples.

### Components

Components define the sets of styles to be applied to identifiers. Identifiers have a one-to-one mapping with a component. In many cases, components are derived from various primitives and define a key-value mapping of all the styles

Components start off something like this:

<span class="note">`[scss/themes/my_custom_theme/components/_examples.scss]`</span>
{% highlight css %}
$STYLEGUIDE_EXAMPLES_ID: example !default;
$STYLEGUIDE_EXAMPLES: () !default;

$a-blackhole: styleguide-add-component($STYLEGUIDE_EXAMPLES_ID, $STYLEGUIDE_EXAMPLES, (
  (default, (
    color        red,
    background   yellow
  ))
), $CONFIG_THEME);
{% endhighlight %}

When this component is invoked via it's identifier, `@include styleguide(example)`, it will collect all the default styles (as defined above) and output them.

#### Adding modifiers and contexts

The default set of styles can be extended with modifiers and contexts:

<span class="note">`[scss/themes/my_custom_theme/components/_example.scss]`</span>
{% highlight css %}
$STYLEGUIDE_EXAMPLES_ID: example !default;
$STYLEGUIDE_EXAMPLES: () !default;

$a-blackhole: styleguide-add-component($STYLEGUIDE_EXAMPLES_ID, $STYLEGUIDE_EXAMPLES, (
  (default, (
    color        red,
    background   yellow
  )),
  (awesome, (
    font-weight  bold,
    nil
  )),
  (in-punchcut, (
    color        white,
    background   nil
  ))
), $CONFIG_THEME);
{% endhighlight %}

Now when we invoke `@include styleguide(awesome example)`, we'll get a new set of styles.

<span class="note">NOTE: you can remove previously defined styles by setting them to nil, like the background example above.</span>

You can also define multiple combinations of variants and contexts:

<span class="note">[scss/themes/my_custom_theme/components/_example.scss]</span>
{% highlight css %}
$STYLEGUIDE_EXAMPLES_ID: example !default;
$STYLEGUIDE_EXAMPLES: () !default;

$a-blackhole: styleguide-add-component($STYLEGUIDE_EXAMPLES_ID, $STYLEGUIDE_EXAMPLES, (
  (default, (
    color        red,
    background   yellow
  )),
  (awesome, (
    font-weight  bold,
    nil
  )),
  (in-punchcut, (
    color        white,
    background   nil
  )),
  (awesome in-punchcut, (
    font-size    20px,
    nil
  ))
), $CONFIG_THEME);
{% endhighlight %}

Now each of these invocations will produce a customized result:

`@include styleguide(example);`

`@include styleguide(awesome example);`

`@include styleguide(example in a punchcut);`

`@include styleguide(awesome example in a punchcut);`

#### Special properties

Archetype supports a few special properties within these data structures to give you even more flexibility. These properties include `drop`, `inherit`, `styleguide`, `selectors`, and `states`.

We'll cover these in more detail in follow up tutorials:

- [Special Keywords](/tutorials/styleguide-keywords)
- [States vs Selectors](/tutorials/styleguide-states-vs-selectors)

#### Plugging it in

Now that we have a new identifier file, let's wire it into the global styleguide:

<span class="note">`[scss/themes/my_custom_theme/_components.scss]`</span>
{% highlight css %}
...
@import "components/examples";
{% endhighlight %}

You now have a new, fully functional style definition, so go get your styleguide on!

#### Extending existing components

You can extend or modify existing core components with additional modifiers and contexts. Here's a quick example for extending the existing copy styles.

{% highlight css %}
$a-blackhole: styleguide-extend-component($STYLEGUIDE_COPY_ID, (
  (in-example, (
    font-size   20px,
    color       red
  ))
), $CONFIG_THEME);
{% endhighlight %}

You've now extended the existing copy styles to support something like <br/> `@include styleguide(copy in an example);`.

We'll talk more about this in a [follow up article](/tutorials/extending-core-components/), so stay tuned.

## Conclusion

Components, primitives, and `styleguide` let you compose a set of building blocks for your site. We'll soon cover how to use these building blocks to build complex, reusable UI patterns.
