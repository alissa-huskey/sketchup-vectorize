require_relative 'geom_mixins/bounding_box'
require_relative 'geom_mixins/point3d'

module Vectorize
  # Namespace for Geom mixin modules.
  #
  module GeomMixins
  end
end

Vectorize::GeomMixins.constants.each do |n|
  Geom.const_get(n).class_eval do
    include Vectorize::GeomMixins.const_get(n)
  end
end
