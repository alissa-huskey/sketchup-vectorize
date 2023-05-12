require_relative "../lib/vectorize/part"
require_relative "test_helper"

class TestPart < Minitest::Test
  def test_part
    list = Stub.new(depth: 0.25)
    group = Sketchup::Group.new(Sketchup::Face.new)
    part = Vectorize::Part.new(group, list)

    assert part
    assert_equal 0.25, part.depth
    assert_equal group, part.entity
    assert_equal list, part.parent
  end

  def test_orientations
    depth = 0.25
    mirrored_faces = Minitest::Mock.new
    group = Sketchup::Group.new(Sketchup::Face.new)
    part = Vectorize::Part.new(group, Stub.new(depth: depth))

    group.stub(:orientations_at_thickness, [mirrored_faces], [depth]) do
      group.stub(:mirrors, [mirrored_faces]) do
        assert_equal [mirrored_faces], part.orientations
      end
    end
  end

  def test_orientation
    mirrored_faces = Stub.new
    part = Vectorize::Part.new(Sketchup::Group.new, Stub.new)

    part.stub(:orientations, [mirrored_faces]) do
      assert_equal(
        mirrored_faces,
        part.orientation,
        "When there is one MirroredFaces object in part.orientations it should be returned"
      )
    end
  end

  def test_orientation_when_assigned
    mirrors = [Stub.new(label: :a), Stub.new(label: b)]
    part = Vectorize::Part.new(Sketchup::Group.new, Stub.new)

    part.stub(:orientations, mirrors) do
      part.orientation = mirrors.last

      assert_equal(
        mirrors.last,
        part.orientation,
        "When part.orientation has been specifically set it should be returned."
      )
    end
  end

  def test_orientation_when_multiple
    mirrors = [Stub.new(label: :a), Stub.new(label: b)]
    part = Vectorize::Part.new(Sketchup::Group.new, Stub.new)

    part.stub(:orientations, mirrors) do
      assert_nil(
        part.orientation,
        "When there are multiple orientations and one has not been assigned, part.orientation should return nil."
      )
    end
  end
end
