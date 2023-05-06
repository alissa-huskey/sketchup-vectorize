require_relative '../lib/vectorize'

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

class Geom::Point3d
  include Mock
  include Vectorize::GeomMixins::Point3d

  def initialize(*xyz)
    xyz = xyz.first if (xyz.length == 1) && xyz.first.is_a?(Array)
    @xyz = xyz
  end

  def to_a
    @xyz
  end

  private

  def _inspect
    @xyz.join(", ")
  end
end

class Sketchup::Entities
  include Mock
  include Vectorize::SketchupMixins::Entities

  attr_accessor :entities
  alias to_a entities
  alias usable entities

  def initialize(*entities)
    entities = entities.first if entities.first.is_a?(Array) && entities.size == 1
    @entities = entities
  end
end

class Sketchup::Entity
  include Mock
  include Vectorize::SketchupMixins::Entity
end

class Sketchup::Face
  include Mock
  include Vectorize::SketchupMixins::Face

  attr_accessor :points, :layer

  def initialize(*entities, points: [])
    entities = entities.first if entities.first.is_a?(Array) && entities.size == 1

    @points = points.map { |x| x.is_a?(Geom::Point3d) ? x : Geom::Point3d.new(x) }
    @entities = Sketchup::Entities.new(entities)
    @layer = Sketchup::Layer.new
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
  include Vectorize::SketchupMixins::ComponentInstance

  def definition
    OpenStruct.new(entities: Sketchup::Entities.new)
  end
end

class Sketchup::Edge
  include Mock
end

class Sketchup::Group
  include Mock
  include Vectorize::SketchupMixins::Group

  attr_accessor :entities

  def initialize(*entities)
    entities = entities.first if entities.first.is_a?(Array) && entities.size == 1

    @entities = Sketchup::Entities.new(entities)
  end
end
