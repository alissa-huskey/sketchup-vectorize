require_relative '../assembly'

module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Selection class.
    #
    module Selection
      include Vectorize::Assembly

      def entities
        self
      end
      alias usable entities

      def usable?
        true
      end
    end
  end
end
