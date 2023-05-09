require_relative '../assembly'

module Vectorize
  module SketchupMixins
    # Namespace for mixins to the {https://ruby.sketchup.com/Sketchup/Face.html Sketchup::Face} class.
    #
    module Face
      include Vectorize::Assembly

      # A list containing the width and height of a face, determined from {#bounds}.
      #
      # @return [Float] The rounded width and height of a face.
      def dimensions
        # this is a flat surface so we know one dimension will be zero
        # we can call the remaining two width and height
        bounds.rounded.reject(&:zero?)
      end

      # Return a list of all verticies positions sorted by their respective `[x, y, z]` values.
      #
      # @return [Array<GeomMixins::Point3d>] A sorted list of {GeomMixins::Point3d} objects.
      def points
        vertices.map(&:position).sort
      end

      # If these faces are mirrors return the axis they are mirrored on,
      # otherwise return `false`.
      #
      # @note Two faces are mirrored when all {Geom::Point3d} objects mirror
      #   their respective {Geom::Point3d} objects from the other face on the
      #   same axis and at the same distance.
      #
      # @param other [Face] The {Face} object th compare to.
      # @return [Symbol, Boolean] The axis that the two faces are mirrored on (`:x`, `:y`, or `:z`) or `false`.
      def mirror?(other)
        # optimization gatekeepers -- the faces can't be mirrors if they are
        # different sizes or have a different number of points or are on the
        # same plane
        return false if points.length != other.points.length
        return false if dimensions.sort != other.dimensions.sort
        return false if plane == other.plane

        # compare each two respective points and return a filtered array of the
        # axis and distance between each pair mirrored points
        # return false right away if any are not mirrored
        respective = other.points.sort
        axises = points.sort.zip(respective).filter_map do |a, b|
          axis = a.mirror?(b)
          return false unless axis
          distance = a.send(axis) - b.send(axis)
          [axis, distance.round(Vectorize::PRECISION)]
        end

        # if all axises and distances are the same return the axis
        # otherwise return false
        (axises.uniq.length == 1) && axises.first.first
      end
    end
  end
end
