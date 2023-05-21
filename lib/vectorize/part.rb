module Vectorize
  # A class to represent an actual part
  #
  class Part
    # @return [Sketchup::Entity] The sketchup object that makes up this part.
    attr_accessor :entity

    # @return [Vectorize::PartsList] The list on which this part appears.
    attr_accessor :parent

    # @return [Vectorize::MirroredFaces] The mirrored faces object that represents
    #   the correct orientation of this part.
    attr_writer :orientation

    attr_writer :depth

    # @param entity [Sketchup::Entity] The sketchup object that makes up this part.
    # @param parent [Vectorize::PartsList] The list on which this part appears.
    def initialize(entity = nil, parent = nil)
      @entity = entity
      @parent = parent
    end

    # @return [Float] The depth of the desired sheet material.
    def depth
      @depth ||= parent.depth
    end

    # @return [String] name of this part
    def name
      (!entity.name || entity.name.empty?) && entity.definition ? entity.definition.name : entity.name
    end

    # @return [Array<Vectorize::MirroredFaces>] A list of mirrored faces at `depth` thickness.
    def orientations
      entity.orientations_at_thickness(depth)
    end

    # @return [Vectorize::MirroredFaces] The mirrored faces object that represents
    #   the correct orientation of this part.
    def orientation
      @orientation ||= (orientations.size == 1 ? orientations.first : nil)
    end

    # @return [Integer] entity id
    def entity_id
      entity.persistent_id
    end

    # Return the group containing the copied face for this part
    #
    def face_copy
      Vectorize.app.group.entities.find { |x| x.get_attribute("Vectorize", "from_entity_id") == entity_id }
    end

    # Create a new group that contains a copy of this parts face
    #
    # @return [Sketchup::Group] A group containing the face copy.
    def layout_face
      return if face_copy

      app = Vectorize.app

      main_group = app.group

      group = app.transaction("Layout Face") do
        # create the new group for this face
        group = main_group.entities.add_group
        group.name = "#{name} Face"

        # save the relationship between the entities
        group.set_attribute("Vectorize", "from_entity_id", entity_id)
        entity.set_attribute("Vectorize", "to_entity_id", group.persistent_id)

        # create the face
        group.entities.build do |builder|
          builder.add_face(*face.flip_up)
        end

        # get the face that was just created
        face = group.faces.first

        # reverse it if needed
        face.reverse! unless face.face_up?

        # return the new group from the transaction block
        group
      end

      # get the size of the Vectorize group
      size = main_group.bounds.height

      # move the new group over so it's not on top of previous faces
      # NOTE: Be sure to do this last, (or first) or the reference to group
      #       will be deleted and won't be available for other operations
      group.move_y!(size + 1)
    end

    # @return [Sketchup::Face] The face to copy
    def face
      unless orientation
        Vectorize.app.error "Orientation nil (entity: ##{entity_id} #{name.inspect})"
        return
      end

      orientation.faces.find(&:face_up?) || orientation.a
    end

    # If the orientation was able to be determined
    #
    # @return [Boolean] True if there is an orientation
    def valid?
      !orientation.nil?
    end
  end
end
