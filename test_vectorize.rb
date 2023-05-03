require 'sketchup-api-stubs/sketchup'
require_relative 'vectorize'
require 'test/unit'

class MockPoint3d < Array
  include Vectorize::GeomMixins::Point3d
end

class TestVectorize < Test::Unit::TestCase
  def test_simple
    assert_true true
  end

  def test_rounded
    params = [
      [[2.9999999999999716, 1.0, 0.0], [3.0, 1.0, 0.0]],
      [[1.1, 0, 0], [1.1, 0, 0]],
    ]

    params.each do |row|
      raw, expected = row
      point = MockPoint3d.new(raw)
      assert_equal point.rounded, expected
    end
  end

  def test_mirror
    params = [
      [[0, 0, 0], [0, 0, 1], true],
      [[5, 2.0, 2], [-5, 2, 2], true],
      [[-10, 7, 25], [20, 7, 25], true],
      [[3.0, 0.0, 0.0], [2.9999999999999716, 1.0, 0.0], true],
      [[25.00000000000001, 0.0, 3.552713678800501e-15], [25.0, 1.0, 0.0], true],
      [[0.0, 1.0, 2.0], [0.1, 1.0, 2.0], true],
      [[0, 0, 0], [0, 0, 0], false],
      [[1, 2, 3], [4, 5, 6], false],
      [[1.5, 2.5, 3], [1, 2, 3], false],
    ]

    params.each do |row|
      x, y, expected = row

      a = MockPoint3d.new(x)
      b = MockPoint3d.new(y)

      assert_equal a.mirror?(b), expected, "#{x}.mirror?(#{y}) was expected to be #{expected}"
    end
  end
end
