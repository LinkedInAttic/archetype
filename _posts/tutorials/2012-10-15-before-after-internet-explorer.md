---
layout    : post
title     : ':before and :after... when IE still matters'
category  : tutorials
tags      : [hacks, browsers, IE]
summary   : 'Learn how to use Archetype mixins to simulate :before and :after support in IE6/7'
description : SUMMARY
author    : eoneill
published : true
weight    : 9
---
{% include config %}

How many times have you thought to yourself...
<blockquote>This thing doesn't belong in my markup. If only IE 7 supported :before I could do this in pure CSS.</blockquote>
only to have to come back and put a random `<span>`, `<b>`, or `<i>` tag into your page.

Well, thanks to the genius of [Nicolas Gallagher](http://nicolasgallagher.com) and other contributors, there's a way to simulate `:before` and `:after` using [CSS expressions](http://nicolasgallagher.com/better-float-containment-in-ie/).

Read the full article on Nicholas' blog for the details, but the basic concept is to use an `expression` (which only works in IE6/7) to insert an element into the DOM that can be styled.

## `ie-pseudo-before` and `ie-pseudo-after`

To simplify this, Archetype provides two mixins for inserting these elements for you.

Here's an example of how this works.

{% highlight css %}
.mail {
  @include ie-pseudo-before($content: '\2709') {
    // any custom IE styles here
  };
  #{$archetype-pseudo-selector}, // this is a special selector created after each call to ie-pseudo-*
  &:before {
    // shared styles
    color: red;
    font-size: 20px;
    content: "\2709"
  }
}
{% endhighlight %}

Easy peasy! IE6/7 will now get a fancy mail icon as well.

## Limitations

Unfortunately, there are some limitations with using this technique. First, it requires JavaScript to be enabled (expressions won't work without it).
Second, and more important, the element is actually inserted into the DOM. This means it will be accessible via JavaScript and will persist even after changing classnames on the parent, which would affect the normal behavior.

Nonetheless, this is a useful feature as long as you can live with the limitations.

Let us know how you're using it.
