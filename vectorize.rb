require 'matrix'

module Vectorize
  PRECISION = 10

  module SketchupMixins
    module Face
      def <=>(other)
        object_id <=> other.object_id
      end

      # Return the width and height of a face
      def size
        bounds.rounded.reject(&:zero?)
      end

      # Return a sorted list of Point3D objects
      def points
        vertices.map(&:position).sort
      end

      # Return true if this face is a mirror of another face
      #
      # This happens when all Point3d objects mirror their respective Point3d
      # objects in the other face.
      def mirror?(other)
        return false if points.length != other.points.length
        return false if size.sort != other.size.sort

        points.each_with_index.all? { |x, i| x.mirror?(other.points[i]) }
      end
    end

    module ComponentInstance
      def entities
        definition.entities
      end

      def faces
        entities.grep(Sketchup::Face)
      end

      # Return a list of mirrored faces
      def mirrors
        pairs = Matrix[faces.permutation(2).map(&:sort).uniq]
        pairs.select { |a, b| a.mirror?(b) }
      end
    end
  end

  module GeomMixins
    module Point3d
      def <=>(other)
        to_a <=> other.to_a
      end

      def rounded
        to_a.map { |x| x.round(Vectorize::PRECISION) }
      end

      # Return true if this point mirrors another point
      #
      # This happens when any two respective numbers are the same and the
      # remaining number is different.
      def mirror?(other)
        return false if self == other

        3.times.any? do |i|
          a = rounded
          b = other.rounded

          (a.delete_at(i) != b.delete_at(i)) && a == b
        end
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

  def self.start
    model = Sketchup.active_model
    selection = model.selection
    return unless selection
    selection.grep(Sketchup::ComponentInstance).first
  end
end
