require_relative 'test_helper'

class TestPoint3d < Minitest::Test
  def test_point
    assert Geom::Point3d.new(0, 0, 0)
  end

  def test_rounded
    cases = [
      Case.new(:input => [2.9999999999999716, 1.0, 0.0], :result => [3.0, 1.0, 0.0]),
      Case.new(:input => [1.1, 0, 0], :result => [1.1, 0, 0]),
    ]

    cases.each do |params|
      point = Geom::Point3d.new(params.input)
      assert_equal point.rounded, params.result
    end
  end

  def test_mirror
    cases = [
      Case.new(
        :x => [0, 0, 0],
        :y => [0, 0, 0],
        :expected => false,
      ),
      Case.new(
        :x => [0, 0, 0],
        :y => [0, 0, 1],
        :expected => :z,
      ),
      Case.new(
        :x => [5, 2.0, 2],
        :y => [-5, 2, 2],
        :expected => :x,
      ),
      Case.new(
        :x => [-10, 7, 25],
        :y => [20, 7, 25],
        :expected => :x,
      ),
      Case.new(
        :x => [3.0, 0.0, 0.0],
        :y => [2.9999999999999716, 1.0, 0.0],
        :expected => :y,
      ),
      Case.new(
        :x => [25.00000000000001, 0.0, 3.552713678800501e-15],
        :y => [25.0, 1.0, 0.0],
        :expected => :y,
      ),
      Case.new(
        :x => [0.0, 1.0, 2.0],
        :y => [0.1, 1.0, 2.0],
        :expected => :x,
      ),
      Case.new(
        :x => [1, 2, 3],
        :y => [4, 5, 6],
        :expected => false,
      ),
      Case.new(
        :x => [1.5, 2.5, 3],
        :y => [1, 2, 3],
        :expected => false,
      ),
    ]

    cases.each do |params|
      a = Geom::Point3d.new(params.x)
      b = Geom::Point3d.new(params.y)

      assert_equal(
        a.mirror?(b),
        params.expected,
        "#{params.x}.mirror?(#{params.y}) was expected to be #{params.expected}"
      )
    end
  end
end
