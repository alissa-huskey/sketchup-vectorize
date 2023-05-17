# Base class for the Vectorize plugin
#
# rubocop:disable Style/RedundantFileExtensionInRequire

require "sketchup.rb"

module Vectorize
  class App
    def model
      Sketchup.active_model
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

      unless group
        puts "Creating new group"
        group = model.entities.add_group
        group.name = "Vectorized"
        group.layer = layer
        group.material = material
      end

      group
    end

    def material
      @material ||= model.materials.find { |x| x.name == "Vectorized" }
      unless @material
        @material = model.materials.add("Vectorized")
        @material.color = Sketchup::Color.new(128, 128, 128, 255)
        @material.alpha = 0.5
      end
      @material
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
      list = PartsList.new(depth, *selected.entities.to_a)
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
