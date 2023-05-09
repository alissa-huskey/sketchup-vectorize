module Vectorize
  # A class to represent two mirrored faces
  #
  class MirroredFaces
    include Enumerable

    # @!attribute
    # @return [Array<Sketchup::Face>] One of the mirrored faces.
    attr_accessor :a, :b

    # @!attribute [r]
    # @return [Array<Sketchup::Material, nil>] A list of two materials to
    #   revert each face to.
    # @see #colorize
    # @see #revert
    attr_reader :saved_material

    # @param a [Sketchup::Face, nil] One of the mirrored faces.
    # @param b [Sketchup::Face, nil] The other mirrored face.
    # @param axis [Symbol, nil] The axis that the two faces are mirrored on
    #   (`:x`, `:y`, or `:z`). (Provided here to avoid recalculation for
    #   optimization.)
    def initialize(a = nil, b = nil, axis = nil)
      @a = a
      @b = b
      @axis = axis
      @saved_material = [nil, nil]
    end

    # @return [Symbol] The axis that the faces are mirrored on (`:x`, `:y`, or `:z`).
    def axis
      @axis ||= a.mirror?(b)
    end

    # Iterates over array elements.
    #
    # @yield [Sketchup::Face] Each of the two faces in turn.
    # @return [self]
    def each(&block)
      faces.each(&block)
      self
    end

    # @return [Array<Sketchup::Face>] The two mirrored faces.
    def faces
      [a, b]
    end

    # @return [Float] The rounded distance between the two faces.
    def distance
      return unless a && b
      distance = a.points.first.distance_to_plane(b.plane)
      distance.round(Vectorize::PRECISION)
    end

    # Save the existing material of both faces to {#saved_material} (for later
    # use by {#revert}) then set them both to `material`.
    #
    # @param material [Sketchup::Material] The material to set both faces to.
    # @return [nil]
    def colorize(material)
      @saved_material = faces.map(&:material)
      faces.each { |f| f.material = material}
      nil
    end

    # Set both faces to the respective materials previously saved by
    # {#colorize}.
    #
    # @return [nil]
    def revert
      faces.zip(saved_material) { |face, material| face.material = material }
      nil
    end
  end
end
