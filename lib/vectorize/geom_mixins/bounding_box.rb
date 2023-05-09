module Vectorize
  module GeomMixins
    # Namespace for mixins to the Geom::BoundingBox class.
    #
    module BoundingBox
      # An array containing the #width, #depth and #height.
      #
      # @return [Array<Integer>] The width, depth, and height.
      def to_a
        [width, height, depth]
      end

      # An array containing the rounded #width, #depth and #height.
      #
      # @return [Array<Integer>] The rounded width, depth, and height.
      def rounded
        to_a.map {|x| x.round(Vectorize::PRECISION)}
      end
    end
  end
end
