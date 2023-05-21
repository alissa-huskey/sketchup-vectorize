module Vectorize
  module SketchupMixins
    # Namespace for mixins to the {https://ruby.sketchup.com/Sketchup/Face.html Sketchup::Face} class.
    #
    module Face
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

        # if all axises and distances are the same and this face is directly
        # connected to all faces except other return the axis otherwise return
        # false
        (axises.uniq.length == 1) && decoupled_faces == [other] && axises.first.first
      end

      # @return [Boolean] True if facing up
      def face_up?
        normal.samedirection?(Z_AXIS)
      end

      # @return [Geom::Vector3d] the x or y axis this face is perpendicular to
      def right_axis
        [X_AXIS, Y_AXIS].find { |a| normal.perpendicular?(a) }
      end

      # @return [Integer] The angle to the Z_AXIS in degrees
      def vertical_angle
        normal.angle_between(Z_AXIS).radians
      end

      # rotate and reverse face if neccessary so that it is face up
      #
      # @return [Array<Sketchup::Point3d] List of points for a correctly
      #   oriented face.
      def flip_up
        # a temporary variable for later
        face = self

        # entities to be deleted at the end of the function
        entities = []

        unless vertical_angle.zero?
          # create a temporary group to rotate
          group = Sketchup.active_model.active_entities.add_group

          # add the existing face
          group.entities.add_face(*vertices.map(&:position))

          # rotate from the left front bottom corner, on the previously
          # determined axis and at the previously determined angle
          tr = Geom::Transformation.rotation(bounds.corner(0), right_axis, vertical_angle.degrees)
          group = group.transform!(tr)

          # explode the group so that the face is oriented to the axises in the
          # outer scope
          entities = group.explode

          # get the face
          face = entities.grep(Sketchup::Face).first
        end

        # store the points
        points = face.vertices.map(&:position)

        # delete the temporary entities
        entities.map { |e| e.erase! if e.respond_to?(:erase!) && !e.deleted? }

        # return the points
        points
      end

      # @return [Array<Sketchup::Face>] List of faces that share an edge
      def connected_faces
        loops.reduce([]) do |faces, loop|
          faces + loop.edges.reduce([]) { |res, edge| res + edge.faces }
        end.uniq
      end

      # @return [Array<Sketchup::Face>] List of faces that are indirectly
      #   connected but do not share an edge
      def decoupled_faces
        all_connected.grep(Sketchup::Face) - connected_faces
      end
    end
  end
end
