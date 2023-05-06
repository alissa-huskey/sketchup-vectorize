require_relative 'test_helper'

class TestFace < Minitest::Test
  def test_face
    assert Sketchup::Face.new(points: [0, 0, 0])
  end

  def test_mirror
    cases = [
      Case.new(
        :a => [[0.0, 0.0, 0.0], [0.0, 0.0, 4.0], [0.0, 4.0, 0.0], [0.0, 4.0, 4.0]],
        :b => [[0.0, 4.0, 0.0], [0.0, 4.0, 4.0], [4.0, 4.0, 0.0], [4.0, 4.0, 4.0]],
        :expected => false,
        :message => "Connected faces of a cube",
      ),
      Case.new(
        :a => [
          [0, 0, 0],
          [100, 0, 0],
          [100, 200, 0],
          [0, 200, 0],
        ],
        :b => [
          [0, 0, 50],
          [100, 0, 50],
          [100, 200, 50],
          [0, 200, 50],
        ],
        :expected => true,
        :message => "Opposite faces of a rectangular cuboid",
      ),
      Case.new(
        :a => [
          [5.165354330708659, 3.421259842519685, 0.0],
          [5.165354330708659, 0.0, 0.0],
          [0.0, 0.0, 0.0],
          [0.0, 3.421259842519685, 0.0]
        ],
        :b => [
          [5.165354330708659, 0.0, 0.26377952755905515],
          [5.165354330708659, 3.421259842519685, 0.26377952755905515],
          [0.0, 3.421259842519685, 0.26377952755905515],
          [0.0, 0.0, 0.26377952755905515]
        ],
        :expected => true,
        :message => "Opposite faces of a real rectangular cuboid",
      ),
      Case.new(
        :a => [
          [0, 2.16215, 0],
          [0.0641609, 1.60984, 0],
          [0.0809728, 2.71225, 0],
          [0.269083, 1.09296, 0],
          [0.301561, 3.22264, 0],
          [0.600801, 0.646732, 0],
          [0.646732, 3.65855, 0],
          [1.03671, 0.301561, 0],
          [1.09296, 3.99026, 0],
          [1.5471, 0.0809728, 0],
          [1.60984, 4.19519, 0],
          [2.0972, 0, 0],
          [2.16215, 4.25935, 0],
          [2.6495, 0.0641609, 0],
          [2.71225, 4.17837, 0],
          [3.16638, 0.269083, 0],
          [3.22264, 3.95779, 0],
          [3.61261, 0.600801, 0],
          [3.65855, 3.61261, 0],
          [3.95779, 1.03671, 0],
          [3.99026, 3.16638, 0],
          [4.17837, 1.5471, 0],
          [4.19519, 2.6495, 0],
          [4.25935, 2.0972, 0],
        ],
        :b => [
          [0, 2.16215, 0.26378],
          [0.0641609, 1.60984, 0.26378],
          [0.0809728, 2.71225, 0.26378],
          [0.269083, 1.09296, 0.26378],
          [0.301561, 3.22264, 0.26378],
          [0.600801, 0.646732, 0.26378],
          [0.646732, 3.65855, 0.26378],
          [1.03671, 0.301561, 0.26378],
          [1.09296, 3.99026, 0.26378],
          [1.5471, 0.0809728, 0.26378],
          [1.60984, 4.19519, 0.26378],
          [2.0972, 0, 0.26378],
          [2.16215, 4.25935, 0.26378],
          [2.6495, 0.0641609, 0.26378],
          [2.71225, 4.17837, 0.26378],
          [3.16638, 0.269083, 0.26378],
          [3.22264, 3.95779, 0.26378],
          [3.61261, 0.600801, 0.26378],
          [3.65855, 3.61261, 0.26378],
          [3.95779, 1.03671, 0.26378],
          [3.99026, 3.16638, 0.26378],
          [4.17837, 1.5471, 0.26378],
          [4.19519, 2.6495, 0.26378],
          [4.25935, 2.0972, 0.26378],
        ],
        :expected => true,
        :message => "Opposite faces of a real sphere",
      ),
    ]

    cases.each do |params|
      a = Sketchup::Face.new(points: params.a)
      b = Sketchup::Face.new(points: params.b)

      assert(
        a.mirror?(b) == params.expected,
        "#{params.message} should #{params.expected ? '' : 'not '}mirror one another."
      )
    end
  end
end
