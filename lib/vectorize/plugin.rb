# Sketchup extension loader.
#
# rubocop:disable Style/RedundantFileExtensionInRequire
# rubocop:disable Style/GlobalVars

require "sketchup.rb"

module Vectorize
  def self.initialize_plugin
    print "Initializing Vectorize Plugin... "
    %w[
        vectorize
        app
        assembly
        geom_mixins
        sketchup_mixins
        mirrored_faces
        part
        parts_list
        observers
    ].each { |name| load "vectorize/#{name}.rb" }

    Vectorize.console_shortcuts
    Vectorize.app.log "Plugin loaded."

    $VECTORIZE_UNLOADED = false
    puts "done."
  end

  def self.app
    @app ||= App.new
  end

  # Unload the plugin
  #
  def self.unload!
    # delete the Vectorize module
    Object.class_eval { remove_const :Vectorize }

    # unrequire all vectorize files
    $LOADED_FEATURES.reject! { |x| x.include?("vectorize") }

    # flag for reloading
    $VECTORIZE_UNLOADED = true
  end

  # Reload the plugin
  #
  def self.reload!
    Vectorize.unload!
    require 'vectorize/plugin'
    Vectorize.initialize_plugin
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
