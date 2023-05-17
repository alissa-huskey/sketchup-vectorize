# Sketchup extension loader.
#
# rubocop:disable Style/RedundantFileExtensionInRequire
# rubocop:disable Style/GlobalVars

require "sketchup.rb"

module Vectorize
  def self.initialize_plugin
    %w[
        vectorize
        app
        assembly
        geom_mixins
        sketchup_mixins
        mirrored_faces
        part
        parts_list
    ].each { |name| load "vectorize/#{name}.rb" }

    Vectorize.console_shortcuts

    $VECTORIZE_UNLOADED = false
  end

  def self.app
    @app ||= App.new
  end

  # Unload the plugin
  #
  def self.unload!
    Object.class_eval { remove_const :Vectorize }
    $LOADED_FEATURES.reject! { |x| x.include? "vectorize" }
    $VECTORIZE_UNLOADED = true
  end

  def self.hello
    UI.messagebox("oh hai there.")
  end

  def self.console_shortcuts
    top = TOPLEVEL_BINDING
    top.local_variable_set(:app, Vectorize.app) unless top.local_variable_defined?(:app)
    top.local_variable_set(:model, Vectorize.app.model) unless top.local_variable_defined?(:model)
  end
end

unless file_loaded?(File.basename(__FILE__)) || $VECTORIZE_UNLOADED
  Vectorize.initialize_plugin
  file_loaded(File.basename(__FILE__))
end
