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
      entity.name.empty? && entity.definition ? entity.definition.name : entity.name
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
      entity.entityID
    end

    # Return the group containing the copied face for this part
    #
    def face
      Vectorize.app.group.entities.find { |x| x.get_attribute("Vectorize", "from_entity_id") == entity_id }
    end

    # Create a new group that contains a copy of this parts face
    #
    # @return [Sketchup::Group] A group containing the face copy.
    def layout_face
      return if face

      # cache the vertices first to avoid context problems
      vertices

      app = Vectorize.app

      main_group = app.group

      group = app.transaction("Layout Face") do
        app.log "Laying out face"

        # create the new group for this face
        group = main_group.entities.add_group
        group.name = "#{name} Face"

        app.log "Group created"

        # save the relationship between the entities
        group.set_attribute("Vectorize", "from_entity_id", entity_id)
        entity.set_attribute("Vectorize", "to_entity_id", group.entityID)

        app.log "Attributes set"

        # create the face from previously computed vertices
        group.entities.build do |builder|
          builder.add_face(vertices)
        end

        app.log "Face built"
        group
      end

      # get the size of the Vectorize group
      size = main_group.bounds.height

      # move the new group over so it's not on top of previous faces
      # NOTE: Be sure to do this last, (or first) or the reference to group
      #       will be deleted and won't be available for other operations
      group = group.move_y!(size + 1)

      app.log "Group moved: #{group.name}"
      app.log "Base context? #{app.base_context?}"

      group
    end

    # @return [Array[Geom::Point3d] list of points of the correctly positioned face
    def vertices
      return @vertices if @vertices

      # start a transaction
      app = Vectorize.app
      app.transaction("Calculate vertices")

      # select the face to copy
      face = orientation.faces.find(&:face_up?) || orientation.a

      # get a version that is face up
      clone = face.flip_up!

      # store the list of points from the correctly positioned face
      @vertices = clone.vertices.map(&:position)

      # now abort the transaction to undo all of the changes
      app.cancel

      # return the list of calculated vertices
      @vertices
    end

    # If the orientation was able to be determined
    #
    # @return [Boolean] True if there is an orientation
    def valid?
      !orientation.nil?
    end
  end
end
