module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Entities class.
    #
    module Entities
      # @return [Array<Sketchup::Entity>] A list of visible and non-deleted entities.
      def usable
        select { |e| e.usable? }
      end
    end
  end
end
