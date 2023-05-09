require_relative '../assembly'

module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::ComponentInstance class.
    #
    module ComponentInstance
      include Vectorize::Assembly

      # From the {Sketchup::ComponentDefinition}.
      #
      # @return [Sketchup::Entities] List of entities.
      # @note For when this method is expected.
      def entities
        definition.entities
      end
    end
  end
end
