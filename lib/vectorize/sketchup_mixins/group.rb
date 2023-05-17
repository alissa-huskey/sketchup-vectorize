require_relative '../assembly'

module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Group class.
    #
    module Group
      include Vectorize::Assembly

      def move_relative!(*xyz)
        app = Vectorize.app

        app.begin("Move group")

        start = transformation.origin
        dest = start + xyz
        vector = start.vector_to(dest)
        tr = Geom::Transformation.translation(vector)
        group = transform!(tr)

        app.commit && group
      end

      def move_x!(distance)
        move_relative!(distance, 0, 0)
      end

      def move_y!(distance)
        move_relative!(0, distance, 0)
      end

      def move_z!(distance)
        move_relative!(0, 0, distance)
      end
    end
  end
end
