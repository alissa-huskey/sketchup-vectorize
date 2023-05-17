require_relative 'test_helper'

class TestFace < Minitest::Test
  def test_face
    assert Sketchup::Face.new(points: [0, 0, 0])
  end

  def test_mirror
    cases = [
      Case.new(
        :a => [
          [0.0, 0.0, 66.0],
          [4.0, 0.0, 87.0],
          [4.0, 4.0, 43.0],
          [0.0, 4.0, 35.0],
        ],
        :b => [
          [0.0, 0.0, 72.0],
          [4.0, 0.0, 88.0],
          [4.0, 4.0, 25.0],
          [0.0, 4.0, 86.0],
        ],
        :expected => false,
        :desc => "Faces with mirrored points at different distances",
      ),
      Case.new(
        :a => [
          [0, 2.63386, 0],
          [1.52066, 1.75591, 0],
          [1.52066, 3.51181, 0],
          [3.04132, 2.63386, 0],
        ],
        :b => [
          [0, 0.877953, 0],
          [1.52066, 0, 0],
          [1.52066, 1.75591, 0],
          [3.04132, 0.877953, 0],
        ],
        :planes => [
          [0.0, 0.0, 1.0, 0.0],
          [0.0, 0.0, 1.0, 0.0],
        ],
        :expected => false,
        :desc => "Faces on the same plane",
      ),
      Case.new(
        :a => [[0.0, 0.0, 0.0], [0.0, 0.0, 4.0], [0.0, 4.0, 0.0], [0.0, 4.0, 4.0]],
        :b => [[0.0, 4.0, 0.0], [0.0, 4.0, 4.0], [4.0, 4.0, 0.0], [4.0, 4.0, 4.0]],
        :expected => false,
        :desc => "Connected faces of a cube",
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
        :expected => :z,
        :desc => "Opposite faces of a rectangular cuboid",
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
        :expected => :z,
        :desc => "Opposite faces of a real rectangular cuboid",
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
        :expected => :z,
        :desc => "Opposite faces of a real sphere",
      ),
    ]

    cases.each do |params|
      a = Sketchup::Face.new(points: params.a)
      b = Sketchup::Face.new(points: params.b)

      mock_method(a, :decoupled_faces, [b])

      unless params.planes.nil?
        a.plane = params.planes[0]
        b.plane = params.planes[1]
      end

      axis = a.mirror?(b)

      message = (params.expected ? "be mirrored on #{params.expected}" : "not be mirrored")
      assert_equal params.expected, axis, "#{params.desc.em} should #{message.em}"
    end
  end

  def test_face_up?
    cases = [
      Case.new(same: true, expected: true, desc: "is in the same direction"),
      Case.new(same: false, expected: false, desc: "is not in the same direction"),
    ]

    cases.each do |params|
      face = Sketchup::Face.new

      normal = Stub.new
      mock_method(normal, :samedirection?, params.same)

      face.stub(:normal, normal) do
        assert_equal(
          params.expected,
          face.face_up?,
          "When the faces's normal vector #{params.desc.em} as the Z-AXIS, face_up? should return #{params.expected.em}"
        )
      end
    end
  end

  def test_right_axis
    x, y = %i[ x y ].map { |axis| Stub.new(axis: axis) }

    mock_consts(X_AXIS: x, Y_AXIS: y) do
      cases = [
        Case.new(x: true, y: false, expected: x, desc: "X_AXIS is and Y_AXIS is not"),
        Case.new(x: false, y: true, expected: y, desc: "X_AXIS is not and Y_AXIS is"),
      ]

      cases.each do |params|
        face = Sketchup::Face.new

        normal = Minitest::Mock.new
        normal.expect(:perpendicular?, params.x, [x]) # X_AXIS
        normal.expect(:perpendicular?, params.y, [y]) # Y_AXIS

        face.stub(:normal, normal) do
          assert_equal(
            params.expected,
            face.right_axis,
            "When the #{params.desc.em} at a right angle to the face's normal, " \
            "right_axis return the #{params.expected.axis.em} axis"
          )
        end
      end
    end
  end

  def test_vertical_angle
    mock_consts(Z_AXIS: Stub.new(axis: :z)) do
      normal = Minitest::Mock.new
      normal.expect(:angle_between, Stub.new(radians: 30), [Z_AXIS])

      face = Sketchup::Face.new
      face.stub(:normal, normal) do
        assert_equal 30, face.vertical_angle
      end
    end
  end

  def test_flip_down!
    # normal.angle_between(Z_AXIS).radians
  end
end
