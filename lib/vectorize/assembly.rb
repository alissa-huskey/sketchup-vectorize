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

    # Return true if this object is a graphic, meaning it is made up of only
    # edges and faces.
    #
    # @return [Boolean] True if object is a graphic.
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

    # @return [Array<Sketchup::Element>] A recursive list of all graphic elements
    def graphics
      return [self] if graphic?

      graphics = []

      children.each do |child|
        if child.graphic?
          graphics << child
        else
          graphics += child.graphics
        end
      end

      graphics
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
        # Can't use the less silly `case e` and `when Class` form here as it
        # does not work for Minitest::Mock objects. For example, with a
        # Sketchup::Group mock:
        #   e === Sketchup::Group    # false
        #   e.is_a(Sketchup::Group)  # true
        #

        case true
        when e.is_a?(Sketchup::Face)
          @facets << e
          @faces << e
        when e.is_a?(Sketchup::Edge)
          @facets << e
          @edges << e
        when e.is_a?(Sketchup::ComponentInstance)
          @components << e
          @children << e
        when e.is_a?(Sketchup::Group)
          @groups << e
          @children << e
        else
          @meta << e
        end
      end

      nil
    end

    # @return [Boolean] True if this object is visible and not deleted.
    #
    def usable?
      visible? && layer.visible? && !deleted?
    end
  end

  # Return true if object is an Assembly
  def self.assembly?(object)
    (object.class < Vectorize::Assembly) == true
  end
end
