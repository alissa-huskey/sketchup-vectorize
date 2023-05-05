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

class Sketchup::Face
  include Mock
  include Vectorize::SketchupMixins::Face

  attr_accessor :points

  def initialize(*points)
    points = points.first if points.first.is_a?(Array) && points.size == 1

    @points = points.map { |x| Geom::Point3d.new(x) }
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
