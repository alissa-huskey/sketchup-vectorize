module Vectorize
  # A class to represent two mirrored faces
  class MirroredFaces
    include Enumerable

    attr_accessor :a, :b
    attr_writer :axis
    attr_reader :saved_material

    def initialize(a = nil, b = nil, axis = nil)
      @a = a
      @b = b
      @axis = axis
      @saved_material = [nil, nil]
    end

    def axis
      @axis ||= a.mirror?(b)
    end

    def each(&block)
      faces.each(&block)
    end

    def faces
      [a, b]
    end

    # Return the distance between faces
    def distance
      return unless a && b
      distance = a.points.first.distance_to_plane(b.plane)
      distance.round(Vectorize::PRECISION)
    end

    # Set both faces to the same material and save the existing material
    def colorize(material)
      @saved_material = faces.map(&:material)
      faces.each { |f| f.material = material}
    end

    # Revert both faces to the saved material
    def revert
      faces.zip(saved_material) { |face, material| face.material = material }
    end
  end
end
