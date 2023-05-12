require_relative "part"

module Vectorize
  # A container class for the list of parts from one or more assemblies
  # (Sketchup::Entity objects) and recursive children.
  #
  class PartsList
    include Enumerable

    # @return [Array<Assembly>] One or more Assembly objects that may
    #   be or contain parts.
    attr_accessor :assemblies

    # @return [Float] The expected depth of the desired sheet material.
    attr_accessor :depth

    # @param depth [Float] The expected depth of the desired sheet material.
    # @param assemblies [Array<Assembly>] One or more Assembly objects that may
    #   be or contain parts.
    def initialize(depth, *assemblies)
      @depth = depth
      @assemblies = assemblies
    end

    # Return a list of Parts objects for all assembly (Sketchup::Entity)
    # objects and recursive children that can be a part.
    #
    # An entity can be a part when it is a graphic (made up of only faces and
    # edges) and has at least one pair of mirrored faces that are the desired
    # distance apart.
    #
    # @return [Array<Part>] List of parts
    def parts
      parts = []
      assemblies.each do |assembly|
        assembly.graphics.each do |graphic|
          mirrors = graphic.orientations_at_thickness(depth)
          (parts << Vectorize::Part.new(graphic, self)) if mirrors
        end
      end
      parts
    end

    # Iterates over the array of parts.
    #
    # @yield [Sketchup::Face] Each of the two faces in turn.
    # @return [self]
    def each(&block)
      parts.each(&block)
      self
    end
  end
end
