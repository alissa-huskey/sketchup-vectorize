require_relative '../lib/vectorize/geom_mixins'
require_relative '../lib/vectorize/sketchup_mixins'

require 'sketchup-api-stubs/sketchup'

# Base add-ons for sketchup mocks
module Mock
  def self.included(base)
    base.class_eval do
      def inspect
        "#{self.class}(#{_inspect})"
      end
    end
  end

  def _inspect
    ""
  end
end

# Mixin to give sane defaults to visible?, deleted? and layer.visible?
#
module MakeUsable
  def self.included(base)
    base.class_eval do
      undef :visible?, :deleted?, :layer

      def visible?
        true
      end

      def deleted?
        false
      end

      def layer
        OpenStruct.new(visible?: false)
      end
    end
  end
end

class Sketchup::DrawingElement
end

class Geom::Point3d
  include Mock

  def initialize(*xyz)
    xyz = xyz.first if (xyz.length == 1) && xyz.first.is_a?(Array)
    @xyz = xyz
  end

  def to_a
    @xyz
  end

  def x
    @xyz[0]
  end

  def y
    @xyz[1]
  end

  def z
    @xyz[2]
  end

  private

  def _inspect
    @xyz.join(", ")
  end
end

class Sketchup::Entities
  include Mock

  attr_accessor :entities
  alias to_a entities
  alias usable entities

  def initialize(*entities)
    entities = entities.first if entities.first.is_a?(Array) && entities.size == 1
    @entities = entities
  end

  def each(&block)
    @entities.each(&block)
    self
  end
end

class Sketchup::Entity
  include Mock
end

class Sketchup::Face
  include Mock

  attr_accessor :points, :layer, :plane

  def initialize(*entities, points: [])
    entities = entities.first if entities.first.is_a?(Array) && entities.size == 1

    @points = points.map { |x| x.is_a?(Geom::Point3d) ? x : Geom::Point3d.new(x) }
    @entities = Sketchup::Entities.new(entities)
    @layer = Sketchup::Layer.new
    @plane = rand
  end

  # used by mirror? as a quick way to tell if two faces are not mirrors
  # by default all faces in tests will have the same same arbitrary dimensions
  def dimensions
    [10, 10]
  end

  private

  def _inspect
    @points.join(", ")
  end
end

class Sketchup::ComponentInstance
  include Mock

  def definition
    OpenStruct.new(entities: Sketchup::Entities.new)
  end
end

class Sketchup::Edge
  include Mock
end

class Sketchup::Drawingelement
  include MakeUsable
end

class Sketchup::Group
  include Mock

  attr_accessor :entities

  def initialize(*entities)
    entities = entities.first if entities.first.is_a?(Array) && entities.size == 1

    @entities = Sketchup::Entities.new(entities)
  end
end
