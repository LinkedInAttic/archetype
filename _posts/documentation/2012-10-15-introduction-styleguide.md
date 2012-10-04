---
layout    : post
title     : Creating Custom Components
category  : tutorials
tags      : [intro, styleguide]
summary   : Learn how Archetype and styleguide() will transform the way designers and developers build complex, scalable, web sites.
published : false
---
{% include config %}

## The inner workings

The [styleguide system](/tutorials/introduction-styleguide/) uses a combination of primitives and components to define a set of robust, reusable styles.

### Primitives

Primitives are simple, configurable values like colors, fonts, and background images. See the [Archetype core primitives]({{ GIT_PATH }}/tree/master/stylesheets/archetype/styleguide/primitives) for some examples.

### Components

Components define the sets of styles to be applied to identifiers. Identifiers have a one-to-one mapping with a component. In many cases, components are derived from various primitives and define a key-value store for all the styles

Components start off something like this:

`[scss/themes/my_custom_theme/components/_examples.scss]`
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

`[scss/themes/my_custom_theme/components/_example.scss]`
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

NOTE: you can remove previously defined styles by setting them to nil, like the background example above.

GOTCHA: a caveat with the data structure is that if you're defining only a single key-value pair, you'll need to specify an extra empty placeholder `nil` (don't ask why, just do it).

You can also define multiple combinations of variants and contexts:

`[scss/themes/my_custom_theme/components/_example.scss]`
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

#### Using inherit

Each set of modifiers and contexts will follow a cascading model, naturally inheriting the styles from previously matching modifiers and contexts. That is, if in our example above, if we invoke <br/> `@include styleguide(awesome example in a punchcut)`, we will get the following output:

{% highlight css %}
color:        white;
background:   yellow;
font-weight:  bold;
font-size:    20px;
{% endhighlight %}

We can take this one step further and inherit between different modifiers/contexts:

[scss/themes/my_custom_theme/components/_example.scss]
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
  (cool, (
    inherit (awesome),
    nil
  ))
  ,
  (in-punchcut, (
    color        white,
    background   nil
  )),
  (awesome in-punchcut, (
    font-size    20px,
    nil
  )),
  (cool in-punchcut, (
    inherit (awesome in-punchcut),
    nil
  ))
), $CONFIG_THEME);
{% endhighlight %}

In this example, cool and awesome can now be used interchangeably.

NOTE: you can only inherit within the same identifier (file).

#### Plugging it in

Now that we have a new identifier file, let's wire it into the global styleguide:

[scss/themes/my_custom_theme/_components.scss]
{% highlight css %}
...
@import "examples";
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

## Conclusion

Components, primitives, and `styleguide` let you compose a set of building blocks for your site. We'll soon cover how to use these building blocks to build complex, reusable UI patterns.
