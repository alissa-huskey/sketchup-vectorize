require_relative '../lib/vectorize/geom_mixins'
require_relative '../lib/vectorize/sketchup_mixins'

require 'sketchup-api-stubs/sketchup'

# Base add-ons for sketchup mocks
module Mock
  def self.included(base)
    base.class_eval do
      attr_accessor :name

      def inspect
        "#{self.class}(#{_inspect})"
      end
    end
  end

  def _from_keywords(kwargs)
    kwargs.each do |key, value|
      send("#{key}=".to_sym, value)
    end
  end

  def _keywords_to_inspect
    []
  end

  def _inspect
    _keywords_to_inspect.map { |key| "#{key}=#{send(key).inspect}" }.join(", ")
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
        OpenStruct.new(visible?: true)
      end
    end
  end
end

# Module for mock classes that take an arbitrary number of arguments on
# instantiation, store them in an array, and then are accessed as an
# enumerable.
#
module Collection
  def self.included(base)
    base.class_eval do
      # Constructor/attrs
      # -----------------
      #

      attr_reader :items

      def initialize(*args, **kwargs)
        self.items = args
        _from_keywords(kwargs)
      end

      def items=(items)
        @items = _array_or_variable(items)
      end

      # Array/Enumerable methods
      # ------------------------
      #

      alias_method :to_a, :items

      def [](key)
        items[key]
      end

      def []=(key, value)
        items[key] = value
      end

      def each(&block)
        items.each(&block)
        self
      end

      # utils
      # -----
      #

      # If there is only one item in args and it is an array, return it.
      #   Otherwise, return args.
      #
      #   For use with methods defined with *args so that they may be called as
      #   either:
      #
      #   method.(a, b, c)
      #   method([a, b, c])
      #
      def _array_or_variable(args)
        args.first.is_a?(Array) && args.size == 1 ? args.first  : args
      end
    end
  end
end

# Module for mock classes that contain a list of entities in a
# Sketchup::Entities object.
#
module EntitiesCollection
  def self.included(base)
    base.class_eval do
      include Collection

      attr_reader :entities

      alias_method :usable, :entities

      def initialize(*args, **kwargs)
        self.items = args
        self.entities = Sketchup::Entities.new(@items)
        _from_keywords(kwargs)
      end

      # Set @entities to a Sketchup::Entities object
      #
      def entities=(args)
        if args.is_a?(Sketchup::Entities)
          @entities = args
        else
          @entities = Sketchup::Entities.new(_array_or_variable(args))
        end
      end

      def to_a
        entities.to_a
      end
    end
  end
end

class Geom::Point3d
  include Mock
  include Collection

  alias xyz items

  def x
    xyz[0]
  end

  def y
    xyz[1]
  end

  def z
    xyz[2]
  end

  private

  def _inspect
    xyz.join(", ")
  end
end

class Sketchup::Entities
  include Mock
  include Collection

  alias entities items
end

class Sketchup::Entity
  include Mock
  prepend MakeUsable
end

class Sketchup::Face
  include Mock
  include EntitiesCollection
  prepend MakeUsable

  attr_reader :points
  attr_writer :plane

  def initialize(*args, points: [], **kwargs)
    self.items = args
    self.entities = Sketchup::Entities.new(@items)
    self.points = points
    _from_keywords(kwargs)
  end

  def points=(points)
    @points = points.map { |x| x.is_a?(Geom::Point3d) ? x : Geom::Point3d.new(x) }
  end

  def plane
    @plane ||= rand
  end

  # used by mirror? as a quick way to tell if two faces are not mirrors
  # by default all faces in tests will have the same same arbitrary dimensions
  def dimensions
    [10, 10]
  end

  private

  def _inspect
    points ? points.join(", ") : ""
  end
end

class Sketchup::ComponentInstance
  include Mock
  include Vectorize::Assembly
  include EntitiesCollection

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

Sketchup::Group.class_eval { remove_method :entities }
class Sketchup::Group
  include Mock
  include EntitiesCollection

  attr_writer :mirrors

  def _keywords_to_inspect
    [:name]
  end
end

class Sketchup::Selection
  include Mock
  include EntitiesCollection
end

def mock_method(obj, name, value)
  obj.instance_eval do
    define_singleton_method name do
      value
    end
  end
end
