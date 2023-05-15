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
        parts_list
    ].each { |name| load "vectorize/#{name}.rb" }

    @app = nil
  end

  def self.app
    @app ||= App.new
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

  class App
    def model
      @model ||= Sketchup.active_model
    end

    def selected
      model.selection
    end
    alias selection selected

    def group
      group = model.entities.grep(Sketchup::Group).find { |x| x.name == "Vectorized" && !x.deleted? }
      return group if group

      puts "Adding Vectorize group..."
      group = model.entities.add_group
      group.name = "Vectorized"
      group.layer = layer
      group
    end

    def layer
      @layer ||= (model.layers.find { |x| x.name == "Vectorized" } || model.layers.add_layer("Vectorized"))
    end

    def list_from_selected(depth)
      PartsList.new(depth, selected)
    end

    def begin(name)
      model.start_operation(name, disable_ui: true)
    end

    def abort
      model.abort_operation
    end

    def commit
      model.commit_operation
    end
  end
end

unless file_loaded?(File.basename(__FILE__))
  Vectorize.initialize_plugin
  Vectorize.hello
  file_loaded(File.basename(__FILE__))
end
