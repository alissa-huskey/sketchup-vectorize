# Vectorize Sketchup Extension
#
# A SketchUp Ruby Extension create a SketchUp extension to create a 2D layout
# of your model for laser cutting, CNC milling, etc. that can be exported to a
# SVG or other vector file.
#
# License: The MIT License (MIT)
# @author Alissa Huskey
# @see http://github.com/alissa-huskey/sketchup-vectorize Github Repo

# Namespace for extension classes and modules.
#
module Vectorize
end

# Number of digits to round to.
# @note (Used for [x, y, z] values and distances.)
Vectorize::PRECISION = 10 unless Vectorize.const_defined?(:PRECISION)
