require_relative "../lib/vectorize/mirrored_faces"
require_relative "test_helper"

class TestAssembly < Minitest::Test
  def test_entities_collections
    # this is really a test of my mock/stub setup
    #
    cases = [
      Case.new(klass: Sketchup::ComponentInstance),
      Case.new(klass: Sketchup::Group),
      Case.new(klass: Sketchup::Selection),
      Case.new(klass: Sketchup::Face),
    ]

    entities = %i[a b c].map { |x| Stub.new(label: x, usable?: true) }

    cases.each do |params|
      obj = params.klass.new(*entities)

      assert obj.entities.map.to_a == entities
      assert obj.entities.each.to_a == entities
      assert obj.entities.usable == entities
      assert obj.to_a == entities
    end
  end

  def test_analyze
    cases = [
      Case.new(klass: Sketchup::ComponentInstance),
      Case.new(klass: Sketchup::Group),
      Case.new(klass: Sketchup::Selection),
    ]

    cases.each do |params|
      obj = params.klass.new(
        Sketchup::Group.new,
        Sketchup::ComponentInstance.new,
        Sketchup::Face.new,
        Sketchup::Edge.new,
        Sketchup::Dimension.new,
      )

      assert_equal 2, obj.facets.size, "facets should contain the edge and face"
      assert_equal 2, obj.children.size, "children should contain the group and component"
      assert_equal 1, obj.faces.size, "faces should contain the face"
      assert_equal 1, obj.edges.size, "edges should contain the edge"
      assert_equal 1, obj.groups.size, "groups should contain the group"
      assert_equal 1, obj.components.size, "components should contain the component"
      assert_equal 1, obj.meta.size, "meta should contain the dimension"
    end
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

  def test_orientations_at_thickness
    cases = [
      Case.new(graphic: true),
    ]
    cases.each do |params|
      group = Sketchup::Group.new

      mirrored_face = Stub.new(distance: 0.25)
      group.stub(:graphic?, params.graphic) do
        group.stub(:mirrors, [mirrored_face]) do
          assert_equal [mirrored_face], group.orientations_at_thickness(0.25)
        end
      end
    end
  end

  def test_mirrors
    origin = Geom::Point3d.new([0,   0,   0])
    a, b = [
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
    ]
    group = Sketchup::Group.new(a, b)

    mock_method(a, :decoupled_faces, [b])

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
      mock_method(x, :graphic?, true)
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
      mock_method(x, :graphic?, true)
    end

    assert_equal graphics, obj.graphics
  end

  def test_graphics_with_children_recursive_two
    # generate a dictionary of groups
    #
    groups = %w[ main a b a1 a2 b1 b2 ].reduce({}) do |res, label|
      res[label.to_sym] = Sketchup::Group.new(name: label)
      res
    end

    # proc to get a group by key from groups
    #
    from_groups = proc { |key| groups[key.to_sym] }

    # define the relationships between groups/selection
    #
    group_main = groups[:main]
    group_main.entities = %i[a b].map(&from_groups)

    group_a = groups[:a]
    group_a.entities = %i[a1 a2].map(&from_groups)

    group_b = groups[:b]
    group_b.entities = %i[b1 b2].map(&from_groups)

    selection = Sketchup::Selection.new(group_main)

    # set up expectations
    #
    mirrors = Stub.new(distance: 0.25) # MirroredFaces object

    %w[ a1 a2 b1 b2 ].map(&from_groups).each do |group|
      mock_method(group, :graphic?, true)
      mock_method(group, :mirrors, [mirrors])
    end

    assert_equal 4, selection.graphics.size
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
