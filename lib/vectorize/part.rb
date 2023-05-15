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

    def name
      entity.name.empty? && entity.definition ? entity.definition.name : entity.name
    end

    # @return [Array<Vectorize::MirroredFaces>] A list of mirrored faces at `depth` thickness.
    def orientations
      entity.orientations_at_thickness(depth)
    end

    # @return [Vectorize::MirroredFaces] The mirrored faces object that represents
    #   the correct orientation of this part.
    def orientation
      (orientations.size == 1 ? orientations.first : nil)
    end

    def entity_id
      entity.entityID
    end

    # Return the group containing the copied face for this part
    #
    def face
      Vectorize.app.group.entities.find { |x| x.get_attribute("Vectorize", "from_entity_id") == entity_id }
    end

    # Create a new group that contains a copy of this parts face
    #
    def copy_face
      return if face

      app = Vectorize.app
      app.begin("[Vectorize] Copy Face: #{entity.name.inspect}")

      main_group = app.group

      # create the new group for this face
      group = main_group.entities.add_group
      group.set_attribute("Vectorize", "from_entity_id", entity_id)
      group.name = "#{name} Face"

      # create the face copy in this group
      face = orientation.a
      group.entities.add_face(face.vertices)

      # save the face group info to the entity attributes
      entity.set_attribute("Vectorize", "to_entity_id", group.entityID)

      # get the size of the Vectorize group
      size = main_group.bounds.height

      # move the new group over
      group.move_y!(size + 1)

      app.commit

      # return the new group
      group
    end
  end
end
