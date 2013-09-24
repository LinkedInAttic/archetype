---
layout    : post
title     : Localization with Archetype
category  : tutorials
tags      : [intro, locale, i18n, l10n]
summary   : CSS can be challenging when you're dealing with multiple languages. Learn some techniques and tactics for dealing with common issues.
description : SUMMARY
author    : eoneill
published : true
weight    : 5
---
{% include config %}

CSS can be challenging when you're dealing with multiple languages. Learn some techniques and tactics for dealing with common issues. There really aren't any locale specific features available for use today.

## Setting your locale

Archetype introduces two Compass configurations for working in multiple locales. You can set these in your `config.rb`.

{% highlight ruby %}
...
locale = en_US
reading = ltr
{% endhighlight %}

These let you define the locale as well as the reading direction (`ltr` or `rtl`).

## `lang()` to the rescue

Now that the locale is set, we can use `lang()` to perform some conditional logic.

a different value for a language
{% highlight css %}
// en_US will get height: 10px
// all other locales will get height: 30px;
height: if(lang(en_US), 10px, 30px);
{% endhighlight %}

a different value for multiple languages
{% highlight css %}
// en_US, de_DE, fr_FR will all get height: 10px
// all other locales will get height: 30px;
height: if(lang(en_US de_DE fr_FR), 10px, 30px);
{% endhighlight %}

multiple different values for multiple languages
{% highlight css %}
@if( lang(en_US de_DE fr_FR) ) {
  height: 20px;
}
@else if( lang(ru_RU cs_CZ tr_TR) ) {
  height: 30px;
}
@else {
  height: 10px;
}
{% endhighlight %}

specifying unique attributes for different languages
{% highlight css %}
// only Japanese and Korean versions will have a width
@if( lang(ja_JP ko_KR) ) {
  width: 100px;
}
{% endhighlight %}

sometimes less is more
{% highlight css %}
// all languages but English, German, and French
@if( not lang(en_US de_DE fr_FR) ) { ... }
{% endhighlight %}

### wildcards

The `lang()` method supports some basic wildcard matching.

For example, you can match against country codes:

{% highlight css %}
// all `JP` or `CN` regions
@if( lang(_JP _CN) ) { ... }
{% endhighlight %}

Or match against language codes:

{% highlight css %}
// all `en` or `zh` languages
@if( lang(en_ zh_) ) { ... }
{% endhighlight %}


<!--
## Poorman's right-to-left

There are existing solutions out there to address many right-to-left issues. [CSSJanus](http://cssjanus.commoner.com/) is an awesome open source project to post-process your CSS files.

If you're not able to integrate these extra tools into your build step, or have other reasons not to use them, Archetype provides some simple methods for dealing with a lot of common RTL issues.

By setting `reading = rtl` in your Compass config, Archetype will render in a right-to-left reading order. This means, all components, mixins, and the [grid](/tutorials/complex-layouts-grid/) in Archetype will flip direction horizontally.

There are other mixins and methods that you can use outside of the core features.

{% highlight css %}
@include margin(0 20px 5px 10px);     // margin: 0 10px 5px 20px;
@include padding-left(20px);          // padding-right: 20px;
@include clear(left);                 // clear: right;
@include float(right);                // float: left;
@include background-position(0 top);  // background-position: 100% top;
@include border-right-color(blue);    // border-left-color: blue;
@include left(20px);                  // right: 20px;
{% endhighlight %}

The `rtl()` method can also be used to wrap content when passing into other mixins that aren't RTL aware:

{% highlight css %}
@include border-radius(rtl(5px 10px 20px 30px, border-radius));
// ...
// border-radius: 10px 5px 30px 20px;
{% endhighlight %}
-->

## More localization fun

Learn more about addressing locale specific font issues with our guide to [Beautiful Typography Everywhere](/tutorials/beautiful-typography-everywhere).