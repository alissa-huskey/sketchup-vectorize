module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Entity class.
    #
    module Entity
      # Compares `self` and `other` by #object_id
      #
      # @note While the resulting sort order of {Entity} objects is essentially
      #   arbitrary, it allows lists of entities to be in the _same_ arbitrary
      #   order. This is useful for comparing the equivalence of two lists of
      #   entities that may contain the same entities but in a different order.
      #
      # @param other [Entity] The entity object to compare to.
      # @return [Integer, nil] A value indicating the result:
      #   [nil]   if the two are incomparable.
      #    [-1]   if `other` is smaller.
      #     [0]   if the two are equal.
      #     [1]   if `other` is larger.
      #
      def <=>(other)
        object_id <=> other.object_id
      end
    end
  end
end
