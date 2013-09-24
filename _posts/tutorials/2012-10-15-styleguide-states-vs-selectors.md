---
layout    : post
title     : TODO
category  : tutorials
tags      : [styleguide, states, selectors ]
summary   : TODO
description : SUMMARY
author    : eoneill
published : true
weight    : 2.2
---

#### Using inherit

Each set of modifiers and contexts will follow a cascading model, naturally inheriting the styles from previously matching modifiers and contexts. That is, if in our example above, if we invoke <br/> `@include styleguide(awesome example in a punchcut)`, we will get the following output:

{% highlight css %}
color:        white;
background:   yellow;
font-weight:  bold;
font-size:    20px;
{% endhighlight %}

We can take this one step further and inherit between different modifiers/contexts:

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
  (cool, (
    inherit (awesome),
    nil
  )),
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

<span class="note">NOTE: you can only inherit within the same identifier. To inherit another identifier, use the `styleguide` keyword.</span>