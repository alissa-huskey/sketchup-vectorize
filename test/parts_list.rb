require_relative "../lib/vectorize/parts_list"
require_relative "test_helper"

class TestPartsList < Minitest::Test
  def test_parts_list
    group = Sketchup::Group.new(Sketchup::Face.new)
    list = Vectorize::PartsList.new(0.25, group)

    assert list
    assert_equal 0.25, list.depth
    assert_equal [group], list.assemblies
  end

  def test_parts
    mirrors = Stub.new(distance: 0.25) # MirroredFaces
    group = Sketchup::Group.new
    list = Vectorize::PartsList.new(0.25, group)

    group.stub(:mirrors, [mirrors]) do
      group.stub(:graphic?, true) do
        assert_equal 1, list.parts.size
      end
    end
  end
end
