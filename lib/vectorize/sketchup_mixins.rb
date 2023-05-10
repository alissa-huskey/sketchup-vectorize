require_relative "sketchup_mixins/component_instance"
require_relative "sketchup_mixins/entities"
require_relative "sketchup_mixins/entity"
require_relative "sketchup_mixins/face"
require_relative "sketchup_mixins/group"
require_relative "sketchup_mixins/selection"

module Vectorize
  # Namespace for Sketchup mixin modules.
  #
  module SketchupMixins
  end
end

Vectorize::SketchupMixins.constants.each do |n|
  Sketchup.const_get(n).class_eval do
    include Vectorize::SketchupMixins.const_get(n)
  end
end
