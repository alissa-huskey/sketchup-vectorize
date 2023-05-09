require_relative "../lib/vectorize/mirrored_faces"
require_relative "test_helper"

class TestAssembly < Minitest::Test
  def test_group
    assert Sketchup::Group.new
  end

  def test_analyze
    group = Sketchup::Group.new(
      Sketchup::Group.new,
      Sketchup::Face.new,
      Sketchup::Edge.new,
      Sketchup::ComponentInstance.new,
      Sketchup::Axes.new,
    )

    assert_equal 2, group.facets.size, "facets should contain the edge and face"
    assert_equal 2, group.children.size, "children should contain the group and component"
    assert_equal 1, group.faces.size, "faces should contain the face"
    assert_equal 1, group.edges.size, "edges should contain the edge"
    assert_equal 1, group.groups.size, "groups should contain the group"
    assert_equal 1, group.components.size, "components should contain the component"
    assert_equal 1, group.meta.size, "meta should contain the axis"
  end

  def test_graphic?
    cases = [
      Case.new(
        :entities => [Sketchup::Face.new, Sketchup::Edge.new],
        :expected => true,
      ),
      Case.new(
        :entities => [],
        :expected => false,
      ),
      Case.new(
        :entities => [Sketchup::Group.new, Sketchup::Face.new, Sketchup::Edge.new],
        :expected => false,
      ),
      Case.new(
        :entities => [Sketchup::Group.new],
        :expected => false,
      ),
    ]
    cases.each do |params|
      group = Sketchup::Group.new(
        params.entities
      )

      assert_equal(
         params.expected, group.graphic?,
         "#{params.expected} expected from graphic?(#{params.entities.inspect})"
      )
    end
  end

  def test_mirrors
    origin = Geom::Point3d.new([0,   0,   0])
    group = Sketchup::Group.new(
      Sketchup::Face.new(points: [
        origin,
        [100, 0,   0],
        [100, 200, 0],
        [0,   200, 0],
      ]),
      Sketchup::Face.new(points: [
        [0,   0,   50],
        [100, 0,   50],
        [100, 200, 50],
        [0,   200, 50],
      ]),
    )

    origin.stub :distance_to_plane, 50 do
      mirror = group.mirrors.first

      assert_equal 1, group.mirrors.size
      assert_instance_of Vectorize::MirroredFaces, mirror
      assert_equal 50, mirror.distance
    end
  end

  def test_graphics_when_graphic
    obj = Sketchup::Group.new
    obj.stub(:graphic?, true) do
      assert_equal(
        [obj], obj.graphics,
        "If object is a graphic, a list containing just that object should be returned."
      )
    end
  end

  def test_graphics_with_children
    children = [Minitest::Mock.new(Sketchup::Group.new)] * 2
    obj = Sketchup::Group.new(*children)

    children.each do |x|
      x.expect(:graphic?, true)
    end

    assert_equal children, obj.graphics
  end

  def test_graphics_with_children_recursive
    grandchildren = [Minitest::Mock.new(Sketchup::Group.new)] * 2
    a = Minitest::Mock.new(Sketchup::Group.new(*grandchildren))
    b = Minitest::Mock.new(Sketchup::Group.new)
    obj = Sketchup::Group.new(a, b)
    graphics = grandchildren + [b]

    graphics.each do |x|
      x.expect(:graphic?, true)
    end

    assert_equal graphics, obj.graphics
  end

  def test_usable?
    cases = [
      Case.new(
        visible: true,
        deleted: false,
        layer: true,
        expected: true,
        desc: "visible and not deleted",
      ),
      Case.new(
        visible: true,
        deleted: true,
        layer: true,
        expected: false,
        desc: "deleted",
      ),
      Case.new(
        visible: false,
        deleted: false,
        layer: true,
        expected: false,
        desc: "obj not visible",
      ),
      Case.new(
        visible: true,
        deleted: false,
        layer: false,
        expected: false,
        desc: "layer not visible",
      ),
    ]

    cases.each do |params|
      obj = Sketchup::Group.new

      # This sure seems dumb, but obj.expect() isn't overwriting the mixin
      # methods, so I'm going with it.
      obj.stub(:visible?, params.visible) do
        obj.stub(:deleted?, params.deleted) do
          obj.stub(:layer, OpenStruct.new(visible?: params.layer)) do
            assert_equal(
              params.expected,
              obj.usable?,
              "usable? should return #{params.expected} when #{params.desc}"
            )
          end
        end
      end
    end
  end
end
