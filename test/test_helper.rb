require "ostruct"
require "minitest/autorun"
require "minitest/reporters"

require "pry"
require "sketchup-api-stubs/sketchup"
require "awesome_print"

require_relative "mocks"

# avoid errors from sketchup extension requires
@testdir = Pathname.new(__FILE__).parent.expand_path
$LOAD_PATH.unshift (@testdir/"mocks").to_s

require_relative "../lib/vectorize"
require_relative "../lib/vectorize/vectorize"

# alias to make faux-paramaratized tests look nicer
class Case < OpenStruct; end

# alias to make arbitrary stubs look nicer
class Stub < OpenStruct; end

class Object
  # for emphasizing text in assertion messages
  def em
    to_s.cyan
  end
end

# breakpoint alias
# instead of: binding.pry
#        use: b.point
#         or: b.pt
alias b binding
alias point pry
alias pt pry

Minitest::Reporters.use!

def assert_equal_or_nil(expected, actual, message = nil)
  if expected.nil?
    assert_nil(actual, message)
  else
    assert_equal(expected, actual, message)
  end
end
