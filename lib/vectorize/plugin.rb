# This is the first page that the SketchUp extension loads.
#
# rubocop:disable Style/RedundantFileExtensionInRequire

require "sketchup.rb"

module Vectorize
  def self.load
    %w[
        vectorize
        assembly
        geom_mixins
        sketchup_mixins
        mirrored_faces
        part
        parts_inventory
    ].each { |name| puts("vectorize/#{name}.rb") }
  end

  def self.reload!
    Object.send(:remove_const, :Vectorize)
    load "vectorize.rb"
  end

  def self.hello
    UI.messagebox("oh hai there")
  end
end

unless file_loaded?(File.basename(__FILE__))
  Vectorize.load
  Vectorize.hello
  file_loaded(File.basename(__FILE__))
end
