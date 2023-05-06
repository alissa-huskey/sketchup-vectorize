require_relative "test_helper"

class TestMirroredFaces < Minitest::Test
  def test_truth
    assert Vectorize::MirroredFaces.new
  end

  def test_mirrors
    origin = Geom::Point3d.new([0, 0, 0])
    faces = [
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
      mirror = Vectorize::MirroredFaces.new(*faces)

      assert_equal 50, mirror.distance
      assert_equal :z, mirror.axis
    end
  end
end
