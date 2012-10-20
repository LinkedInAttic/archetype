---
layout    : post
title     : Supported Browsers
category  : documentation
tags      : [browsers]
summary   : Sometimes, you just want things to work.
description : SUMMARY
published : false
weight    : 3
meta :
  date : false
---
{% include config %}

## Everything

Thanks to the awesome work of [Compass](http://compass-style.org), [Normalize.css](http://git.io/normalize) and other pioneers of the web, Archetype provides full cross-browser support to all major browsers, as far back as Internet Explorer 6<sup>†</sup>.

<p style="text-align: center;"><img src="{{ ASSET_PATH }}/images/logos/browsers.png{{ CACHE_BURST }}" alt="Chrome, Safari, Firefox, Internet Explorer, Opera, iOS, Android" /></p>

### † Limitations

Archetype uses a combination of _progressive enhancement_ and _graceful degradation_ to provide support for all browsers. This section will outline limitations and known issues.

- if you're using the `table-cell` method for grids, older versions of IE have some issue (we recommend sticking with the `float` or `inline-block` methods)
