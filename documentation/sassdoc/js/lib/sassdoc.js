(function(window, document, $, undefined) {
  window.Sassdoc || (window.Sassdoc = {});
  window.Sassdoc.init = function() {
    var sassdoc,
        rendered = 0,
        templates = ['nav', 'toc', 'view'],
        filters = {
          'functions' : 1,
          'mixins'    : 1,
          'privates'  : -1
        },
        settings = $.extend(window.Sassdoc.settings, {
          docs: 'sassdoc.json'
        }),
        sources = {},
        showIt;

    Array.prototype.remove = function(from, to) {
      var rest = this.slice((to || from) + 1 || this.length);
      this.length = from < 0 ? this.length + from : from;
      return this.push.apply(this, rest);
    };

    function isRenderDone() {
      return templates.length == rendered;
    }

    function parseTarget(target, source, e) {
      var invoked = [];
      target = target.replace('#','').split(',');
      for(var i=target.length; i--; ) {
        var action, what, other, t = target[i].split(':');
        if(t.length > 1) {
          action = t[0];
          what  = t[1];
          other = t[2];
        }
        else {
          what  = t[0];
          action = (what === 'all') ? 'category' : 'method';
        }
        showIt(action, what, other, source, e, invoked[action]);
        invoked[action] = true;
      }
    }

    function query(name){
      var q = unescape(window.location.search) + '&',
          regex = new RegExp('.*?[&\\?]' + name + '=(.*?)&.*'),
          val = q.replace(regex, "$1");
      return val == q ? undefined : val;
    }

    function parseURL(get) {
      switch(get) {
        case 'options':
          $.extend(settings, {
            docs: query('docs')
          });
        break;
        case 'target':
        default:
          parseTarget(window.location.hash.replace('#', ''));
        break;
      }
    }

    function sortByName(a, b) {
      return (a.name > b.name) ? 1 : -1;
    }
    function sortByCategory(a, b) {
      return (a.category > b.category) ? 1 : -1;
    }

    function formatData(sassdoc) {
      var data = {};
      data.toc = [];
      data.methods = [];
      for(var category in sassdoc) {
        var toc = {},
            methods = sassdoc[category],
            normCategory = category.replace(/[ \:\.\/\\]/g,'-');
            tocMethods = [];
        for(var key in methods ) {
          var method = $.extend({}, methods[key]),
              signature = [];
          // if it begins with an underscore, it assume it's private
          method['private'] == method['private'] || /^_.*/.test(key);
          // if this isn't a private method, use hyphens instead of underscores
          if(!method['private']) {
            key = key.replace('_', '-');
          }
          // normalize the param/return types
          function normalizeTypes(types) {
            return types.replace(/\|/g, ' | ').replace(/\*/, 'Any');
          }

          function getAcceptableValues(description) {
            var pattern = /.*\[(.*|.*)\].*/,
                match = description.match(pattern),
                values = match ? match[1].replace(/\|/g, ' | ') : false;
            return values;
          }

          function decorateDescription(description, only) {
            var patterns = {
              variable: /\$[a-z0-9\_\-]+/gi,
              value:    /(true|false|[0-9]+(px|em|%)|`(.*)`)/gi,
              link:     /(http(s?)):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/gi,
              email:    /[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/gi,
              see:      {
                g: /(\@see )((([a-z0-9\_\-]+[\(\)]*))[, ]*)*/gi,
                i: /(\@see )((([a-z0-9\_\-]+[\(\)]*))[, ]*)*/i
              }
            }
            for(var p in patterns) {
              if(only) {
                if(!$.inArray(only, p)) {
                  continue;
                }
              }
              switch(p) {
                case 'see':
                  /* TODO: this doesn't work correctly yet, need to improve the regex
                  var global = patterns[p].g,
                      individual = patterns[p].i;
                  description = description.replace(individual, function(match, unit) {
                    return '<a href="#method:'+match+'">'+match+'</a>';
                  });
                  */
                break;
                case 'link':
                  description = description.replace(patterns[p], function(match, unit) {
                    return '<a href="'+match+'" target="_blank">'+match+'</a>';
                  });
                break;
                case 'email':
                  description = description.replace(patterns[p], function(match, unit) {
                    return '<a href="mailto:'+match+'">'+match+'</a>';
                  });
                break;
                default:
                  description = description.replace(patterns[p], function(match, unit) {
                    return '<span class="'+p+'">'+match+'</span>';
                  });
                break;
              }
            }
            return description;
          }

          if(method.param ) {
            for(var i=0, len=method.param.length; i<len; i++) {
              var param = method.param[i];
              signature.push(param.name);
              if(param.type) {
                param.type = normalizeTypes(param.type);
              }
              if(param.description) {
                param.acceptable = getAcceptableValues(param.description);
                // lazy match all instances of "optional" unless its preceded by "and"
                if(/^((?!and).)*(optional)/.test(param.description)) {
                  param.optional = true;
                }
                param.description = decorateDescription(param.description);
              }
            }
          }
          if(method['return']) {
            if($.isArray(method['return'])) {
              method['return'] = method['return'][0];
            }
            if(method['return'].type) {
              method['return'].type = normalizeTypes(method['return'].type);
            }
            var d = decorateDescription(method['return'].description || method['return']);
            if(method['return'].description) {
              method['return'].description = d;
            }
            else {
              method['return'] = d;
            }
          }
          if(method.author) {
            for(var i=0, len=method.author.length; i<len; i++) {
              var author = method.author[i];
              author = decorateDescription(author, ['email']);
            }
          }
          if(method.usage) {
            var usage = method.usage,
                replacer = (method.mixin ? '@include ': '');
            function removeIndex(array, index) {
              var rest = array.slice((to || from) + 1 || array.length);
              array.length = from < 0 ? array.length + from : from;
              return array.push.apply(array, rest);
            }
            for(var i=usage.length; i--; ) {
              if(!usage[i] || usage[i] === ':') {
                usage.remove(i);
              }
              else {
                usage[i] = usage[i].replace(/^\=/, replacer);
              }
            }
          }
          method.name = key;
          method.source || (method.source = category);
          method.signature = signature.join(', ');
          // eventually this should link to a repo
          method.source_clean = method.source.replace(/[\/\.]/g, '-');
          sources[method.source_clean] = method.source;
          tocMethods.push({
            name:       method.name,
            'private':  method['private'],
            'function': method['function'] || false,
            mixin:      method.mixin || false
          });
          if(method.see) {
            for(var i=method.see.length; i--; ) {
              // strip off any parens
              method.see[i] = method.see[i].replace(/\(.*\)/, '');
            }
          }
          method.hasReferences = (method.link && method.link.length || method.see && method.see.length);
          method.category_clean = normCategory;
          data.methods.push(method);
        }
        data.toc.push({
          category: category,
          category_clean: normCategory,
          methods:  tocMethods.sort(sortByName)
        });
      }
      data.methods = data.methods.sort(sortByName);
      data.toc = data.toc.sort(sortByCategory);
      return data;
    }

    function render(tmpl, raw) {
      dust.loadSource(dust.compile(raw, tmpl));
      dust.render(tmpl, sassdoc, function(error, html){
        $(function() {
          $('#tmpl-'+tmpl).html(html);
          rendered++;
        });
      });
    }

    function getTemplate(tmpl) {
      $.ajax('tmpl/'+tmpl+'.tmpl', {
        success: function(html) {
          render(tmpl, html);
        }
      });
    }
    // early parse URL, get options
    parseURL('options');
    $.getJSON(settings.docs, function(response) {
      sassdoc = formatData(response);
      for(var i=templates.length; i--;) {
        getTemplate(templates[i]);
      }
      $(function() {
        var $toc = $('#tmpl-toc'),
            $view = $('#tmpl-view'),
            $nav = $('#tmpl-nav'),
            $body = $('body'),
            $win = $(window),
            $revealed = $();

        showIt = function(action, what, other, source, e, preserve) {
          what = what.replace('#','');
          if(action !== 'filter' && action !== 'toggle' && !preserve) {
            $revealed.removeClass('reveal');
          }
          else if(action === 'filter') {
            other || (other = -1 * filters[what]);
            other = 1 * other;
            filters[what] = other;
          }
          switch(action) {
            case 'category':
              if(what === 'all') {
                $revealed = $body.removeClass('hide-all-categories').removeClass('hide-all-methods').removeClass('hide-all-sources').removeClass('show-index');
              }
              else {
                $body.addClass('hide-all-categories');
                $revealed = $('.reveal, .is-category-'+what).addClass('reveal');
              }
            break;
            case 'source':
              // if there's a source viewer, use it, otherwise
              if(settings.source_viewer && (/^(http(s?)):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?$/i).test(settings.source_viewer)) {
                var h = $win.height() - 81,
                    $iframe = $('<iframe>').attr('src', settings.source_viewer.replace(/\{FILE\}/gi, sources[what]).replace(/\{LINE\}/gi, other))
                      .attr('height', h).css('height', h+'px');
                $win.resize(function() {
                  var h = $win.height() - 81;
                  $('iframe', '.source-viewer').attr('height', h).css('height', h+'px');
                })
                $('.source-viewer').html($iframe);
                showIndex('viewer');
                return;
              }
              else {
                $body.addClass('hide-all-sources');
                $revealed = $('.is-source-'+what).addClass('reveal');
              }
            break;
            case 'filter':
              var f = ['addClass', 'removeClass'];
              $body[f[(other < 0) ? 0 : 1]]('hide-'+what);
              $('.'+what, $('.filters'))[f[(other > 0) ? 0 : 1]]('label-info');
            break;
            case 'toggle':
              if(what === 'unminimize') {
                $(source).hide().parent().parent().find('.minimize').removeClass('minimize');
                // break early
                return;
              }
              else {
                $body.toggleClass('toggle-'+what);
                $('.'+what, $('.toggles')).toggleClass('label-info');
                if(what === 'search') {
                  parseURL();
                }
              }
            break;
            case 'method':
              $body.addClass('hide-all-methods');
              $revealed = $('#'+what).addClass('reveal');
            break;
            case 'search':
              if(!what || what.length < 2) {
                // bailout
                window.location.hash = '';
                $revealed = $();
                break;
              }
              previousSearch = what;
              $body.addClass('hide-all-methods');
              var searchFor = what.split(' '),
                  searchForIds = '[id*='+searchFor.join('][id*=')+']';
              // text search (only searches 'overview' section)
              if($body.hasClass('toggle-search')) {
                $('.is-method', '.methods').each(function() {
                  var $text = $('.overview', $(this)).text(),
                      match = true;
                  for(var i=searchFor.length; i--; ) {
                    if($text.indexOf(searchFor[i]) === -1) {
                      match = false;
                      break;
                    }
                  }
                  if(match) {
                    $(this).addClass('reveal');
                  }
                });
              }
              // search for matching IDs
              $(searchForIds).addClass('reveal');
              // recompose the $revealed collection
              $revealed = $('.reveal');
              window.location.hash = 'search:'+searchFor.join(' ');
            break;
          }
          showIndex();
        }

        function isIndex() {
          var len = $revealed.length;
          if(!len) {
            return true;
          }
          var tmp = ['private', 'function', 'mixin'],
              disqualifiers = [],
              disqualified = 0;
          for(var i=tmp.length; i--; ) {
            if($body.hasClass('hide-'+tmp[i]+'s')) {
              disqualifiers.push('is-'+tmp[i]);
            }
          }

          if(disqualifiers.length) {
            disqualifiers = '.'+disqualifiers.join(', .');
            $revealed.each(function() {
              if($(this).is(disqualifiers)) {
                disqualified++;
              }
            });
          }
          return (len === disqualified);
        }

        function showIndex() {
          var index = 'show-index',
              viewerClass = 'show-viewer',
              speed = 'medium',
              viewer, info;
          if(arguments) {
            if(arguments[0] === 'viewer') {
              viewer = true;
            }
            else if(arguments[0]) {
              speed = arguments[0];
            }
          }
          if(viewer) {
            $revealed.removeClass('reveal');
            $('body').addClass('show-viewer').addClass(index);
          }
          else {
            $body.removeClass(viewerClass);
            if(isIndex()) {
              $body.addClass(index);
            }
            else {
              $body.removeClass(index);
            }
          }
          // stop all scrolling animation
          $('body, html').queue([]).stop();
          $.scrollTo($body, speed);
        }

        // delegate all the link clicks
        $body.delegate('a', 'click', function(e) {
          parseTarget($(this).attr('href'), this, e);
        })
        .delegate('.filters a, .toggles a', 'click', function(e) {
          e.preventDefault();
        });

        // dirty search
        $body.delegate('#method-search', 'keyup', function() {
          parseTarget('search:'+$(this).val().replace(':',' '));
        });

        function whenReady() {
          setTimeout(function() {
            if(isRenderDone()) {
              parseURL();
            }
            else {
              whenReady();
            }
          }, 10);
        }
        whenReady();
      });
    });
  };
})(window, document, jQuery);