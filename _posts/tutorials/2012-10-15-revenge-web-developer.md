---
layout    : post
title     : Revenge of a Web Developer
category  : tutorials
tags      : [browsers, hacks, targeting]
summary   : Learn how target-browser() can help you address cross-browser woes
description : SUMMARY
author    : eoneill
published : false
weight    : 12
---
{% include config %}

Let's be honest. As web developers and designers, we haven't been given the best best canvas to paint our picture on.

Browsers are amazing pieces of technology, but they don't always behave the way they should.
Standards and best practices are our _shield_ in the battle to create gorgeous websites.
Compass and Normalize help make the playing field that much more even, but sometimes you need a sword to get the job done.

These woes aren't limited to just IE. For example, Opera (arguably the _most_ standards compliant browser) calculates percentage based widths different than every other browser out there.

So how do you deal with these issues? This is where `target-browser()` comes in, the _sword_ for your scabbard.

## target-browser()

There are numerous ways to target CSS at specific browsers. Paul Irish has documented [many hacks](http://paulirish.com/2009/browser-specific-css-hacks/) and [other methods](http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/) for targeting browsers.
The `target-browser()` mixin abstracts this logic, so you can just write your CSS without remembering the hacks.
This also gives you one convenient place to update if you decide to drop support for a given browser.

<span class="note">NOTE: we leverage many of [Compass' browser configurations](http://compass-style.org/reference/compass/support/), including `$legacy-support-for-ie`.</span>

### Pre-requisite

For many of the IE targeting methods to work, you'll need to use this pattern to bind some class names to the `<html>` tag.

{% highlight html %}
<!--[if lt IE 7]><html class="ie ie6 lte9 lte8 lte7"><![endif]-->
<!--[if IE 7]><html class="ie ie7 lte9 lte8 lte7"><![endif]-->
<!--[if IE 8]><html class="ie ie8 lte9 lte8"><![endif]-->
<!--[if IE 9]><html class="ie ie9 lte9"><![endif]-->
<!--[if gt IE 9]><!--><html><!--<![endif]-->
{% endhighlight %}

<span class="note">NOTE: this pattern is taken from an older version of [HTML5Boilerplate](http://html5boilerplate.com/). We're working on a solution to allow this to be configurable for different classname patterns.</span>

### Example Usage

{% highlight css %}
// target IE6 only
@include target-browser(ie 6, padding, 10px);

// target IE <= 7
@include target-browser(ie lte 7, padding, 10px);

// target IE 8 and 9
@include target-browser(ie 8 9, padding, 10px);

// target webkit
@include target-browser(webkit, padding, 10px);

// you can also pass the block @content if you're using Sass 3.2 or higher
@include target-browser(gecko) {
  padding: 10px;
  margin: 20px;
}

// fix our Opera issue
width: 81.5%;
@include target-browser(opera, width, 82%);
{% endhighlight %}

## Conclusion

These should be used only when other suitable workarounds aren't available. This should be a tool of last resort, not the first thing you run to.

Also be aware that currently targeting Opera, Webkit, or Firefox is all-or-nothing (including mobile), so be cautious. IE targeting gives more granularity allowing you to target specific versions.

Now go forth and wield your new sword wisely with ninja like precision (or with Berserker Rage, it's up to you).
