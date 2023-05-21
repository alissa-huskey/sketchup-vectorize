# Base class for the Vectorize plugin
#
# rubocop:disable Style/RedundantFileExtensionInRequire

require "logger"
require "pathname"
require "sketchup.rb"

module Vectorize
  class App
    # @return [Sketchup::Model] The active Sketchup model
    #
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
        log "Creating new Vectorize group"
        group = model.entities.add_group
        group.name = "Vectorized"
        group.layer = layer
        group.material = material
      end

      group
    end

    # Find or create the default material to use for flattened faces.
    #
    # @return [Sketchup::Material]
    def material
      @material ||= model.materials.find { |x| x.name == "Vectorized" }
      unless @material
        log "Creating new Vectorize material"
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
      PartsList.new(depth, *selected.to_a)
    end

    # Start a transaction
    #
    # @param title [String] Action to be preformed.
    def transaction(title)
      if @transaction
        error "Transaction in progress: #{@transaction.inspect} when trying to start #{title.inspect}."
        return
      end

      @transaction = title
      log "Starting transaction: #{title}"
      model.start_operation(title, disable_ui: true)

      return unless block_given?

      result = yield

      commit

      result
    end

    # Abort a transaction
    def cancel
      unless @transaction
        error "No transaction to abort."
        return
      end

      log "Aborting transaction: #{@transaction}"
      model.abort_operation
      @transaction = nil
    end

    # Commit a transaction
    def commit
      unless @transaction
        error "No transaction to commit."
        return
      end

      model.commit_operation
      log "Transaction committed: #{@transaction}"
      @transaction = nil
    end

    # Log an info message.
    #
    # @param message [String] the message to log.
    def info(message)
      logger.info(message)
    end
    alias log info

    # Log an error message.
    #
    # @param message [String] the message to log.
    def error(message)
      logger.error(message)
    end

    # Log an debug message.
    #
    # @param message [String] the message to log.
    def debug(message)
      logger.debug(message)
    end

    # @return [Logger] The logger for this app.
    def logger
      # Log levels: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
      @logger ||= Logger.new(log_handler, level: Logger::DEBUG)
    end

    # @return [File] The IO handler for logging.
    def log_handler
      return @log_handler if @log_handler

      @log_handler ||= File.open(log_path, "a")
      @log_handler.sync = true
      @log_handler
    end

    # @return [Pathname] Path to the log file.
    def log_path
      @log_path ||= HOME/"Library"/"Logs"/"vectorize.log"
    end

    # @return [Boolean] True if currently working in the base context
    def base_context?
      model.entities == model.active_entities
    end

    # Close all contexts until reaching the base context.
    #
    def close_context
      model.close_active until base_context?
    end
  end
end
Vectorize::App::HOME = Pathname.new(Dir.home) unless Vectorize::App.const_defined?(:PRECISION)
