---
layout    : post
title     : Beautiful Typography Everywhere
category  : tutorials
tags      : [fonts, targeting, browsers]
summary   : 
description : SUMMARY
author    : eoneill
published : false
weight    : 6
---
{% include config %}

## The Problem

{% highlight css %}
font-family: Arial, Helvetica, sans-serif;
{% endhighlight %}
or was it...
{% highlight css %}
font-family: Helvetica, Arial, sans-serif;
{% endhighlight %}

So, Helvetica looks _gorgeous_ on a Mac, but [horrible on Windows](http://www.sitepoint.com/truetype-font-variants-and-antialiasing/) (see references below). So how do we ensure we get the best experience in both worlds?

[Paul Irish](http://paulirish.com/) recommends [`font-family: sans-serif;`](http://css-tricks.com/sans-serif/).
This is a great solution because, as Paul describes, it will use the browser defined sans-serif font, which [by default in most browsers](http://blog.mhurrell.co.uk/post/2946358183/updating-the-helvetica-font-stack), is Arial on Windows and Helvetica on Mac.
The caveat here, is this will use _whatever_ font is defined as the browser default. If the user chooses, this can be [Comic Sans](http://bancomicsans.com/), Wingdings, or any other user specified font. This can tarnish your branding or even break your page layouts.

To help ensure you get the best font everywhere, this guide will show you how to create targetable font stacks.

## Pre-requisite

For this to work, we rely on a classname attached to the `<hml>` element to help us target specific operating systems. Here's an example using simple User Agent sniffing in JavaScript (used on this site):

{% highlight javascript %}
(function() {var p = {
  'linux'   : /(x11|linux)/i,
  'android' : /android/i,
  'ipad'    : /ipad/i,
  'iphone'  : /iphone/i,
  'mac'     : /mac/i,
  'win'     : /win/i
}, os = 'os-other', ua = navigator.appVersion, c = ['js'], d = document.documentElement;for(var i in p) { if(p.hasOwnProperty(i) && p[i].test(ua)) c.push('os-' + i); }d.className = d.className.replace(/(^|\s)no-js(\s|$)/, '$1'+c.join(' ')+'$2'); })();
{% endhighlight %}

<span class="note">NOTE: we'd recommend doing this server side if possible, but if the client has JS disabled, at the worst they'll fallback to a safe `sans-serif`</span>

## font-family() - mixin it up

Archetype provides a mixin for abstracting font stack logic. It's interface is fairly simple, taking a single parameter that maps to your font stack.

{% highlight css %}
body {
  @include font-family(sans-serif);
}
{% endhighlight %}

This'll generate
{% highlight css %}
body {
  font-family: sans-serif;
}
.os-win body {
  font-family: Arial, sans-serif;
}
.os-mac body {
  font-family: Helvetica, Arial, sans-serif;
}
.os-linux body {
  font-family: Helvetica, FreeSans, "Liberation Sans", Helmet, Arial, sans-serif;
}
{% endhighlight %}

Archetype ships with three pre-configured font stacks: `sans-serif`, `serif`, and `monospace`. These can be extended to add new font stacks or extend the defaults.

## Japanese, Korean, ohmy!

Now that we can serve custom font stacks to each operating system and get the best looking fonts everywhere, let's make sure we're also delivering the best font for _everyone_.

Internationalization and localization brings a whole other challenge to the table. Helvetica might look great in Latin scripts, but isn't the best choice for cyrillic or Asiatic glyphs.
Using serif fonts might look great for your headlines in English, but does the style translate when you're viewing the site in Japanese?

No worries! Archetype provides a mechanism for these cases too. Take a look at this snippet taken from the core font stack definition:

{% highlight css %}
$CORE_SAFE_FONTS: (
  (sans-serif, (
    (default, (
      (default (sans-serif)),
      (ko_KR ("Malgun Gothic", default))
    )),
    (win, (
      (default (Arial, sans-serif)),
      (ja_JP (メイリオ, Meiryo, "ＭＳ Ｐゴシック", "MS PGothic", default)),
      (ko_KR nil)
    )),
    (mac, (
      (default (Helvetica, Arial, sans-serif)),
      (ja_JP ("Hiragino Kaku Gothic Pro", "ヒラギノ角ゴ Pro W3", "ＭＳ Ｐゴシック", "MS PGothic", default)),
      (ko_KR nil)
    )),
    (linux, (
      (default (Helvetica, FreeSans, "Liberation Sans", Helmet, Arial, sans-serif)),
      (CJK nil)
    ))
  )),
  (serif, (
    (default, (
      (default (Georgia, serif)),
      (CJK nil) // dont use any serif fonts in CJK langs
    )),
    nil
  )),
  (monospace, (
    (default, (
      (default (Menlo, Monaco, Consolas, "Courier New", monospace)),
      nil
    )),
    nil
  ))
);
{% endhighlight %}

Now that's a mouthful. But this definition let's us easily define all of our font stacks for all locales, on all OS's.

Now, when compiled setting `locale = ko_KR` (for Korean) in your Compass config, using the same `font-family(sans-serif)` mixin will generate:

{% highlight css %}
body {
  font-family: "Malgun Gothic", sans-serif;
}
{% endhighlight %}

Setting `locale = ja_JP` (for Japanese), will generate:

{% highlight css %}
body {
  font-family: sans-serif;
}
.os-win body {
  font-family: メイリオ, Meiryo, "ＭＳ Ｐゴシック", "MS PGothic", sans-serif;
}
.os-mac body {
  font-family: "Hiragino Kaku Gothic Pro", "ヒラギノ角ゴ Pro W3", "ＭＳ Ｐゴシック", "MS PGothic", sans-serif;
}
{% endhighlight %}


This ensures you can use the best font for everyone, everywhere. So when I use `font-family(sans-serif)`, I always get the appropriate sans-serif font stack. Likewise, when I use `font-family(serif)`, I don't degrade the experience for those locales that aren't serif friendly.

### _italics_, CAPS, and more woes

Italics make it hard to read Asiatic characters, forcing character case in Turkish is [broken](http://www.w3.org/International/tests/html-css/text-transform/results-text-transform#special) in all but the [latest versions of Firefox](https://developer.mozilla.org/en-US/docs/CSS/text-transform). To help address these issues, Archetype provides a few extra helper mixins.

`@include uppercase();` lets you safely apply `text-transform: uppercase` with the side effects

`@include small-caps();` will give you a safe interface for applying `font-variant: small-caps`

`@include font-style(italic);` will prevent Asiatic characters from being italicized

## Conclusion

Typography is awesome. I hope this helps you create gorgeous cross-browser, cross-platform, cross-locale font stacks for even sharer looking websites.

## References

- [Updating the Helvetica font stack](http://blog.mhurrell.co.uk/post/2946358183/updating-the-helvetica-font-stack)
- [Helvetica Neue variants for use on the web // Steve Cochrane](http://stevecochrane.com/v3/2007/12/13/helvetica-neue-variants-for-use-on-the-web/)
- [Better Helvetica](http://css-tricks.com/snippets/css/better-helvetica/)
- [Sans-Serif](http://css-tricks.com/sans-serif/)
- [Helvetica Neue Light](http://tumblr.gesteves.com/post/36097597/helvetica-neue-light)
- [Internet Explorer 9 Type 1 Font Bug, Helvetica IE9 Bug](http://bobbyjoneswebdesign.blogspot.com/2011/12/internet-explorer-9-type-1-font-bug.html)
- [Is there a web-safe Helvetica Neue CSS font-family stack?](http://rachaelmoore.name/posts/design/css/web-safe-helvetica-font-stack/)
- [Truetype, Font Variants and Antialiasing](http://www.sitepoint.com/truetype-font-variants-and-antialiasing/)
- [“helvetica, arial”, Not “arial, helvetica”](http://meiert.com/en/blog/20080220/helvetica-arial/)
