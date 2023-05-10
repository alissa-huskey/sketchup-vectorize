# This is the first page that the SketchUp extension loads.
#
# rubocop:disable Style/RedundantFileExtensionInRequire

require "sketchup.rb"

module Vectorize
  def self.initialize_plugin
    %w[
        vectorize
        assembly
        geom_mixins
        sketchup_mixins
        mirrored_faces
        part
        parts_inventory
    ].each { |name| load "vectorize/#{name}.rb" }
  end

  # Unload the plugin
  #
  def self.unload!
    Object.class_eval { remove_const :Vectorize }
    $LOADED_FEATURES.reject! { |x| x.include? "vectorize" }
    true
  end

  def self.hello
    UI.messagebox("oh hai.")
  end
end

unless file_loaded?(File.basename(__FILE__))
  Vectorize.initialize_plugin
  Vectorize.hello
  file_loaded(File.basename(__FILE__))
end
