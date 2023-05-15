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

  def test_parts_mixed_orientations_at_depth
    # generate a dictionary of groups
    #
    groups = %w[ main a b c d ].reduce({}) do |res, label|
      res[label.to_sym] = Sketchup::Group.new(name: label)
      res
    end

    # proc to get a group by key from groups
    #
    from_groups = proc { |key| groups[key.to_sym] }

    # define the relationships between groups/selection
    #
    group = groups[:main]
    group.entities = %i[a b c d].map(&from_groups)

    %w[ a c ].map(&from_groups).each do |graphic|
      mock_method(graphic, :graphic?, true)
      mock_method(graphic, :mirrors, [Stub.new(distance: 0.25)])
    end

    %w[ b d ].map(&from_groups).each do |graphic|
      mock_method(graphic, :graphic?, true)
      mock_method(graphic, :mirrors, [Stub.new(distance: 2)])
    end

    # create the list
    #
    list = Vectorize::PartsList.new(0.25, group)

    # assertions
    #
    assert_equal 2, list.parts.size
  end

  def test_parts_no_orientations_at_depth
    # generate a dictionary of groups
    #
    groups = %w[ main a b c ].reduce({}) do |res, label|
      res[label.to_sym] = Sketchup::Group.new(name: label)
      res
    end

    # proc to get a group by key from groups
    #
    from_groups = proc { |key| groups[key.to_sym] }

    # define the relationships between groups/selection
    #
    group = groups[:main]
    group.entities = %i[a b c].map(&from_groups)

    %w[ a b c ].map(&from_groups).each do |group|
      mock_method(group, :graphic?, true)
      mock_method(group, :mirrors, [Stub.new(distance: 3)])
    end

    # create the list
    #
    list = Vectorize::PartsList.new(0.25, group)

    # assertions
    #
    assert_equal 0, list.parts.size
  end

  def test_parts_recursive
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

    # create the list
    #
    list = Vectorize::PartsList.new(0.25, selection)

    # assertions
    #
    assert_equal 4, list.parts.size
  end
end
