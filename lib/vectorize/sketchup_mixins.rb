require_relative 'assembly'

module Vectorize
  module SketchupMixins
    module ComponentInstance
      include Vectorize::Assembly
      def entities
        definition.entities
      end
    end

    module Entities
      # filter out entities that should be ignored
      def entities
        self
      end

      def usable
        all = entities || []
        all.select { |e| e.visible? && e.layer.visible? && !e.deleted? }
      end
    end

    module Entity
      def <=>(other)
        object_id <=> other.object_id
      end
    end

    module Face
      include Vectorize::Assembly

      # Return the rounded width and height of a face
      def dimensions
        # this is a flat surface so we know one dimension will be zero
        # we can call the remaining two width and height
        bounds.rounded.reject(&:zero?)
      end

      # Return a sorted list of Sketchup::Point3D objects
      def points
        vertices.map(&:position).sort
      end

      # If these faces are mirrors, return the axis they are mirrored on,
      # otherwise return false
      #
      # This happens when all Point3d objects mirror their respective Point3d
      # objects in the other face on the same axis
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

    module Group
      include Vectorize::Assembly
    end

    module Selection
      include Vectorize::Assembly
    end
  end
end

Vectorize::SketchupMixins.constants.each do |n|
  Sketchup.const_get(n).class_eval do
    include Vectorize::SketchupMixins.const_get(n)
  end
end
