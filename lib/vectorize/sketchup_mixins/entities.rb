module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Entities class.
    module Entities
      # @return [Sketchup::Entities] #self
      # @note For when this method is expected.
      def entities
        self
      end

      # @return [Array<Sketchup::Entity>] A list of visible and non-deleted entities.
      def usable
        all = entities || []
        all.select { |e| e.visible? && e.layer.visible? && !e.deleted? }
      end
    end
  end
end
