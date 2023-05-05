require 'ostruct'
require 'minitest/autorun'
require 'minitest/reporters'

require 'pry'
require 'sketchup-api-stubs/sketchup'

require_relative 'mocks'
require_relative '../lib/vectorize'

# alias to make faux-paramaratized tests look nicer
Case = OpenStruct

# breakpoint alias
# instead of: binding.pry
#        use: b.point
#         or: b.pt
alias b binding
alias point pry
alias pt pry

Minitest::Reporters.use!
