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

    # @param entity [Sketchup::Entity] The sketchup object that makes up this part.
    # @param parent [Vectorize::PartsList] The list on which this part appears.
    def initialize(entity = nil, parent = nil)
      @entity = entity
      @parent = parent
    end

    # @return [Float] The depth of the desired sheet material.
    def depth
      parent.depth
    end

    # @return [Array<Vectorize::MirroredFaces>] A list of mirrored faces at `depth` thickness.
    def orientations
      @orientations ||= entity.orientations_at_thickness(depth)
    end

    # @return [Vectorize::MirroredFaces] The mirrored faces object that represents
    #   the correct orientation of this part.
    def orientation
      @orientation ||= (orientations.size == 1 ? orientations.first : nil)
    end
  end
end
