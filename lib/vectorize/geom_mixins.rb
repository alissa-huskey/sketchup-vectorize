module Vectorize
  module GeomMixins
    module Point3d
      def <=>(other)
        to_a <=> other.to_a
      end

      def rounded
        to_a.map { |x| x.round(Vectorize::PRECISION) }
      end

      # Return the axis (:x, :y, :z) that the other point is a mirror of,
      # otherwise return false
      #
      # This happens when any two respective numbers are the same and the
      # remaining number is different.
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
        # NOTE: be sure to return false explicitly here, or [:x, :y, :z] will
        false
      end
    end

    module BoundingBox
      def to_a
        [width, height, depth]
      end

      def rounded
        to_a.map {|x| x.round(Vectorize::PRECISION)}
      end
    end
  end
end

Vectorize::GeomMixins.constants.each do |n|
  Geom.const_get(n).class_eval do
    include Vectorize::GeomMixins.const_get(n)
  end
end
