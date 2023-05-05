require 'sketchup'
# require_relative 'vectorize'

Vectorize::SketchupMixins.constants.each do |n|
  Sketchup.const_get(n).class_eval do
    include Vectorize::SketchupMixins.const_get(n)
  end
end

Vectorize::GeomMixins.constants.each do |n|
  Geom.const_get(n).class_eval do
    include Vectorize::GeomMixins.const_get(n)
  end
end
