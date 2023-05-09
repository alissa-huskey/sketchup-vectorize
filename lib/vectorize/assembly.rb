require 'matrix'

module Vectorize
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

  # Return true if object is an Assembly
  def self.assembly?(object)
    (object.class < Vectorize::Assembly) == true
  end
end
