module Archetype::Functions::CSS

  private

  #
  # given a set of related properties, compute the property value
  #
  # *Parameters*:
  # - <tt>hsh</tt> {Hash} the hash of styles
  # - <tt>property</tt> {String} the original property we're looking for
  # *Returns*:
  # - {Hash} the derived styles
  #
  def self.get_derived_styles_via_router(hsh, property)
    base = get_property_base(property)
    handler = "get_derived_styles_router_for_#{base}"
    # if we don't need any additional processing, stop here
    return nil if not self.respond_to?(handler)
    base = /^#{base}/
    value = self.method(handler).call(hsh.select { |key, value| key =~ base }, property)
    value = value[normalize_property_key(property)] if value.is_a?(Hash)
    return value
  end
end

%w(animation background border list margin_padding outline overflow target transition).each do |router|
  require "archetype/functions/css/routers/#{router}"
end