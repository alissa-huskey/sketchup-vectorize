require_relative "../lib/vectorize/parts_inventory"
require_relative "test_helper"

class TestPartsInventory < Minitest::Test
  def test_parts_inventory
    group = Sketchup::Group.new(Sketchup::Face.new)
    inventory = Vectorize::PartsInventory.new(0.25, group)

    assert inventory
    assert_equal 0.25, inventory.depth
    assert_equal [group], inventory.assemblies
  end

  def test_parts
    mirrors = Stub.new(distance: 0.25) # MirroredFaces
    group = Sketchup::Group.new
    inventory = Vectorize::PartsInventory.new(0.25, group)

    group.stub(:mirrors, [mirrors]) do
      group.stub(:graphic?, true) do
        assert_equal 1, inventory.parts.size
      end
    end
  end
end
