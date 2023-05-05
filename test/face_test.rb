require_relative 'test_helper'

class TestVectorize < Minitest::Test
  def test_face
    assert Sketchup::Face.new(0, 0, 0)
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
          # x, y, z
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
    ]

    cases.each do |params|
      a = Sketchup::Face.new(params.a)
      b = Sketchup::Face.new(params.b)

      assert(
        a.mirror?(b) == params.expected,
        "#{params.message} should #{params.expected ? '' : 'not '}mirror one another."
      )
    end
  end
end
