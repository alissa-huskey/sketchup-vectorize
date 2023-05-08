require 'matrix'

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

  # An object that may be a part or may contain parts
  module Assembly
    # attr_reader-like method that defines any missing instance variables by
    # calling analyze first
    def self.collection_reader(*attrs)
      attrs.each do |attr|
        attr_reader attr

        define_method "#{attr}" do
          analyze unless instance_variable_defined? "@#{attr}"
          instance_variable_get "@#{attr}"
        end
      end
    end

    collection_reader :faces, :edges, :groups

    # return [Array <Sketchup::ComponentInstance]
    collection_reader :components

    # @return [Array <Sketchup::Component::Instance, Sketchup::Group]
    collection_reader :children

    # @return [Array <Sketchup::Edge, Sketchup::Face]
    collection_reader :facets

    # @return [Array <Sketchup::Element>] Non-graphical elements (any not included above)
    collection_reader :meta

    def initialize(*args)
      analyze
      super(*args)
    end

    # faces are on the same plane or there's only one
    def surface?
      faces && ((faces.size == 1) || (faces.map(&:plane).uniq == 1))
    end

    # Made up of only edges and faces
    def graphic?
      !facets.empty? && children.empty?
    end

    # Return a list of mirrored faces
    def mirrors
      pairs = Matrix[faces.permutation(2).map(&:sort).uniq]

      pairs.filter_map do |a, b|
        axis = a.mirror?(b)
        MirroredFaces.new(a, b, axis) if axis
      end
    end

    # Categorize all Sketchup::Entity objects
    def analyze
      @facets = []
      @edges = []
      @faces = []
      @children = []
      @components = []
      @groups = []
      @meta = []

      entities.usable.each do |e|
        case e
        when Sketchup::Face
          @facets << e
          @faces << e
        when Sketchup::Edge
          @facets << e
          @edges << e
        when Sketchup::ComponentInstance
          @components << e
          @children << e
        when Sketchup::Group
          @groups << e
          @children << e
        else
          @meta << e
        end
      end
    end
  end

  # TODO: An actual part that will be vectorized
  # class Part
  # end

  module SketchupMixins
    module ComponentInstance
      include Vectorize::Assembly
      def entities
        definition.entities
      end
    end

    module Entities
      # filter out entities that should be ignored
      def entities
        self
      end

      def usable
        all = entities || []
        all.select { |e| e.visible? && e.layer.visible? && !e.deleted? }
      end
    end

    module Entity
      def <=>(other)
        object_id <=> other.object_id
      end
    end

    module Face
      include Vectorize::Assembly

      # Return the rounded width and height of a face
      def dimensions
        # this is a flat surface so we know one dimension will be zero
        # we can call the remaining two width and height
        bounds.rounded.reject(&:zero?)
      end

      # Return a sorted list of Sketchup::Point3D objects
      def points
        vertices.map(&:position).sort
      end

      # If these faces are mirrors, return the axis they are mirrored on,
      # otherwise return false
      #
      # This happens when all Point3d objects mirror their respective Point3d
      # objects in the other face on the same axis
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

        # if all axises and distances are the same return the axis
        # otherwise return false
        (axises.uniq.length == 1) && axises.first.first
      end
    end

    module Group
      include Vectorize::Assembly
    end

    module Selection
      include Vectorize::Assembly
    end
  end

  module GeomMixins
    module Point3d
      def <=>(other)
        to_a <=> other.to_a
      end

      def rounded
        to_a.map { |x| x.round(Vectorize::PRECISION) }
      end

      # Return the axis (:x, :y, :z) that the other point is a mirror of,
      # otherwise return false
      #
      # This happens when any two respective numbers are the same and the
      # remaining number is different.
      def mirror?(other)
        return false if self == other

        # iterate over each of the three axises
        %i[x y z].each_with_index do |axis, i|
          # get a fresh array of the x, y, z values of both points
          a = rounded
          b = other.rounded

          # if the values at this axis are different and the remaining two
          # values in the array are the same, return the axis
          return axis if (a.delete_at(i) != b.delete_at(i)) && a == b
        end

        # if we've gotten this far, the points are not mirrors
        # NOTE: be sure to return false explicitly here, or [:x, :y, :z] will
        false
      end
    end

    module BoundingBox
      def to_a
        [width, height, depth]
      end

      def rounded
        to_a.map {|x| x.round(Vectorize::PRECISION)}
      end
    end
  end

  # Return true if object is an Assembly
  def self.assembly?(object)
    (object.class < Vectorize::Assembly) == true
  end
end

Vectorize::PRECISION = 10 unless Vectorize.const_defined?(:PRECISION)

Vectorize::SketchupMixins.constants.each do |n|
  Sketchup.const_get(n).class_eval do
    include Vectorize::SketchupMixins.const_get(n)
  end
end

Vectorize::GeomMixins.constants.each do |n|
  Geom.const_get(n).class_eval do
    include Vectorize::GeomMixins.const_get(n)
  end
end
