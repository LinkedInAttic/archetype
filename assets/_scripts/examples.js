(function($) {
  'use strict';
  $(function() {
    var $codes = $('section.code', '#main');
    $codes.hide();
    $codes.before('<a href="javascript:void(0);" class="toggle-code">Toggle Code</a>');
    $codes.prev().on('click', function(evt) {
      $(this).next().toggle();
      evt.preventDefault();
    });
  });
})(jQuery);
