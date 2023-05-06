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

    assert_equal 2, group.facets.size
    assert_equal 2, group.children.size
    assert_equal 1, group.faces.size
    assert_equal 1, group.edges.size
    assert_equal 1, group.groups.size
    assert_equal 1, group.components.size
    assert_equal 1, group.meta.size
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
end
