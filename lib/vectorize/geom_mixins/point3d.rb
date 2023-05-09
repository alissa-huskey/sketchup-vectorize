module Vectorize
  module GeomMixins
    # Namespace for mixins to the Geom::Point3d class.
    #
    module Point3d
      # Compares `self` and `other` by their respective `[x, y, z]` values.
      #
      # @note While the resulting sort order of {Point3d} objects is somewhat
      #   arbitrary, it allows lists of points to be in the _same_ arbitrary
      #   order. This is useful for comparing the equivalence of two lists of
      #   points that may contain the same points but in a different order.
      #
      # @param other [Point3d] The point to compare to.
      # @return [Integer, nil] A value indicating the result:
      #   [nil]   if the two are incomparable.
      #    [-1]   if `other` is smaller.
      #     [0]   if the two are equal.
      #     [1]   if `other` is larger.
      #
      def <=>(other)
        to_a <=> other.to_a
      end

      # An array containing the rounded `[x, y, z]` values.
      #
      # @return [Array<Integer>] The rounded `[x, y, z]` values.
      def rounded
        to_a.map { |x| x.round(Vectorize::PRECISION) }
      end

      # If these points are mirrored return the axis they are mirrored on,
      # otherwise return `false`.
      #
      # @note Two points are mirrored when any two respective [x, y, z] values
      #   are the same and the remaining value is different.
      #
      # @param other [Point3d] The {Point3d} object to compare to.
      # @return [Symbol, Boolean] The axis that the two points are mirrored on
      #   (`:x`, `:y`, or `:z`) or `false`.
      def mirror?(other)
        return false if self == other

        # iterate over each of the three axises
        %i[x y z].each_with_index do |axis, i|
          # get a fresh array of the x, y, z values of both points
          a = rounded
          b = other.rounded

          # if the values at this axis are different and the remaining two
          # values in the array are the same, return the axis
          return axis if (a.delete_at(i) != b.delete_at(i)) && a == b
        end

        # if we've gotten this far, the points are not mirrors
        false

        # NOTE: be sure to return false explicitly here to avoid returning the
        #       evaluation result of the previous block ([:x, :y, :z])
      end
    end
  end
end
