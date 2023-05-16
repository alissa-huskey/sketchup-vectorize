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

    # @return [Sketchup::Selection] the current selection
    #
    def selected
      model.selection
    end
    alias selection selected

    # Find or create the Vectorized group
    #
    # @note Do not cache as Sketchup may delete and recreate groups unexpectedly
    # @return [Sketchup::Group] The Vectorized group
    def group
      group = model.entities.grep(Sketchup::Group).find { |x| x.name == "Vectorized" && !x.deleted? }
      return group if group

      group = model.entities.add_group
      group.name = "Vectorized"
      group.layer = layer
      group
    end

    # Find or create the Vectorized layer
    #
    # @return [Sketchup::Layer] The Vectorized layer
    def layer
      @layer ||= (model.layers.find { |x| x.name == "Vectorized" } || model.layers.add_layer("Vectorized"))
    end

    # Create a PartsList from currently selected entities.
    #
    # @param depth [Float] The thickness of sheet material to find parts.
    # @return [PartsList]
    def list_from_selected(depth)
      PartsList.new(depth, selected)
    end

    # Start a transaction
    #
    # @param name [String] Action to be preformed.
    def begin(name)
      model.start_operation(name, disable_ui: true)
    end

    # Abort a transaction
    def abort
      model.abort_operation
    end

    # Commit a transaction
    def commit
      model.commit_operation
    end
  end
end

unless file_loaded?(File.basename(__FILE__))
  Vectorize.initialize_plugin
  file_loaded(File.basename(__FILE__))
end
