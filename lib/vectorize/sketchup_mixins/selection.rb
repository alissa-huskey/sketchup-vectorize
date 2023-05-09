require_relative '../assembly'

module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Selection class.
    #
    module Selection
      include Vectorize::Assembly
    end
  end
end
