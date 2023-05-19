require_relative '../assembly'

module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Group class.
    #
    module Group
      include Vectorize::Assembly

      # Move group relative to the current position.
      #
      # @param distance [Array<Float>] An array of three positive or negative
      #   numbers representing the distance to move on the x, y, and z axis.
      # @return [Sketchup::Group] The transformed group.
      def move_relative!(*xyz)
        app = Vectorize.app

        app.transaction("Move group") do
          start = transformation.origin
          dest = start + xyz
          vector = start.vector_to(dest)
          tr = Geom::Transformation.translation(vector)
          transform!(tr)
        end
      end

      # Move group relative to the current position on the x axis.
      #
      # @param distance [Float] The positive or negative distance to move.
      # @return [Sketchup::Group] The transformed group.
      def move_x!(distance)
        move_relative!(distance, 0, 0)
      end

      # Move group relative to the current position on the y axis.
      #
      # @param distance [Float] The positive or negative distance to move.
      # @return [Sketchup::Group] The transformed group.
      def move_y!(distance)
        move_relative!(0, distance, 0)
      end

      # Move group relative to the current position on the z axis.
      #
      # @param distance [Float] The positive or negative distance to move.
      # @return [Sketchup::Group] The transformed group.
      def move_z!(distance)
        move_relative!(0, 0, distance)
      end
    end
  end
end
