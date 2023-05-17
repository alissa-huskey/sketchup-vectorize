require_relative "../lib/vectorize/mirrored_faces"
require_relative "test_helper"

class TestMirroredFaces < Minitest::Test
  def test_initialize
    cases = [
      Case.new(
        args: [],
        a: nil, b: nil,
      ),
      Case.new(
        args: %i[a b axis],
        a: :a, b: :b
      )
    ]

    cases.each do |params|
      mirror = Vectorize::MirroredFaces.new(*params.args)
      assert_equal_or_nil params.a, mirror.a
      assert_equal_or_nil params.b, mirror.b
      assert_equal [nil, nil], mirror.saved_material
    end
  end

  def test_axis
    cases = [
      Case.new(axis: nil, message: "When nil on initialize axis should default to the value of a.mirror?(b)"),
      Case.new(axis: :y, message: "When axis is passed on initialize that value should be returned"),
    ]

    cases.each do |params|
      a, b = [ Sketchup::Face.new ] * 2
      mirror = Vectorize::MirroredFaces.new(a, b, params.axis)

      a.stub(:mirror?, :y) do
        assert_equal :y, mirror.axis, params.message
      end
    end
  end

  def test_mirrors
    origin = Geom::Point3d.new([0, 0, 0])
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

    origin.stub :distance_to_plane, 50 do
      mirror = Vectorize::MirroredFaces.new(a, b)

      mock_method(a, :decoupled_faces, [b])

      assert_equal 50, mirror.distance
      assert_equal :z, mirror.axis
    end
  end

  def test_colorize
    a, b = [ Minitest::Mock.new(Sketchup::Face.new) ] * 2

    [a, b].each do |x|
      x.send(:expect, :material, "red")
      x.send(:expect, :material=, nil, ["red"])
    end

    mirror = Vectorize::MirroredFaces.new(a, b, :x)
    mirror.colorize("red")

    assert_equal %w[red red], mirror.saved_material
    assert_mock a
    assert_mock b
  end

  def test_distance
    a, b = [ Minitest::Mock.new(Sketchup::Face.new) ] * 2
    point = Minitest::Mock.new
    mirror = Vectorize::MirroredFaces.new(a, b)

    a.expect(:points, [point])
    b.expect(:plane, [0, 0, 0, 0])
    point.expect(:distance_to_plane, 0.25, [[0, 0, 0, 0]])

    assert_equal 0.25, mirror.distance
  end

  def test_faces
    a, b = [ Sketchup::Face.new ] * 2
    mirror = Vectorize::MirroredFaces.new(a, b)
    assert_equal [a, b], mirror.faces
  end

  def test_revert
    a, b = [ Minitest::Mock.new(Sketchup::Face.new) ] * 2
    mirror = Vectorize::MirroredFaces.new(a, b, :x)

    mirror.stub(:saved_material, %w[green green]) do
      [a, b].each do |x|
        x.send(:expect, :material=, nil, ["green"])
      end

      mirror.revert
    end

    assert_mock a
    assert_mock b
  end
end
