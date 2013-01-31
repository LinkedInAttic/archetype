---
layout    : post
title     : Getting Started with Archetype
category  : documentation
tags      : [intro, install]
summary   : Get your environment up and running and create your first Archetype project
description : SUMMARY
published : true
weight    : 1
meta :
  date : false
---
{% include config %}

## Why Archetype?

If you haven't already, check out our [introductory blog post](/blog/hello-world/) which will cover some benefits of Archetype.

## Installation

In this section we'll cover the steps needed to get Archetype setup. This guide assumes you've already got [Compass installed](http://compass-style.org/install/).

### Install the gem

{% highlight bash %}
[sudo] gem install archetype
{% endhighlight %}

Instead of installing the gem directly via the command line, we recommend using [Bundler](http://gembundler.com/) to manage your gem dependencies.

### Creating a new project with Archetype

{% highlight bash %}
compass create ~/workspace/your-project -r archetype --using archetype
{% endhighlight %}

### Adding Archetype to an existing Compass project

In your `config.rb`, add

{% highlight ruby %}
require "archetype"
{% endhighlight %}

### Import Archetype into your Sass file

{% highlight css %}
@import "archetype";
{% endhighlight %}

Learn more about [configuring Archetype](/documentation/configuration/), [creating custom themes](/tutorials/custom-themes/), and hit the ground running with our [off-the-shelf components](/components/).
