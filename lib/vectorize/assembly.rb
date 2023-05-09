require 'matrix'

module Vectorize
  # Mixins for Sketchup::Element objects that may be a part or may contain one
  # or more parts.
  #
  # @note Used for Sketchup::Group, Sketchup::Component and
  #   Sketchup::Selection.
  #
  # @note This is technically a mixin for various Sketchup classes, so it may
  #   seem like it should be in the SketchupMixins module. However, that is for
  #   modules with direct equivalent classes in the Sketchup modulue.
  #
  module Assembly
    # attr_reader-like method that defines any missing instance variables by
    # calling analyze first.
    #
    # @note Intended to be used only in the definition of this module.
    # @!visibility private
    def self.collection_reader(*attrs)
      attrs.each do |attr|
        attr_reader attr

        define_method "#{attr}" do
          analyze unless instance_variable_defined? "@#{attr}"
          instance_variable_get "@#{attr}"
        end
      end
    end

    # @!attribute [r]
    # @return [Array<Sketchup::Face>] List of faces.
    # @see #analyze
    collection_reader :faces

    # @!attribute [r]
    # @return [Array<Sketchup::Edge>] List of edges.
    # @see #analyze
    collection_reader :edges

    # @!attribute [r]
    # @return [Array<Sketchup::Group>] List of groups.
    # @see #analyze
    collection_reader :groups

    # @!attribute [r]
    # @return [Array<Sketchup::ComponentInstance>] List of components instances.
    # @see #analyze
    collection_reader :components

    # @!attribute [r]
    # @return [Array<Sketchup::Component::Instance, Sketchup::Group>] List of component instances and groups.
    # @see #analyze
    collection_reader :children

    # @!attribute [r]
    # @return [Array<Sketchup::Edge, Sketchup::Face>] List of edges and faces.
    # @see #analyze
    collection_reader :facets

    # @!attribute [r]
    # @return [Array<Sketchup::Element>] List of non-graphical elements (any not included in other element lists.).
    # @see #analyze
    collection_reader :meta

    # @!visibility private
    def initialize(*args)
      analyze
      super(*args)
    end

    # Return true if this object is a "graphic".
    #
    # Made up of only edges and faces
    def graphic?
      !facets.empty? && children.empty?
    end

    # Return a list of mirrored faces
    #
    # @return [Array<Sketchup::Face>] A list of mirrored faces
    def mirrors
      pairs = Matrix[faces.permutation(2).map(&:sort).uniq]

      pairs.filter_map do |a, b|
        axis = a.mirror?(b)
        MirroredFaces.new(a, b, axis) if axis
      end
    end

    # Categorize all usable {Sketchup::Entity} objects into their respective
    # element lists.
    #
    # @return [nil]
    # @see Vectorize::SketchupMixins::Entities#usable
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
