# Vectorize Sketchup Extension
#
# A SketchUp Ruby Extension create a SketchUp extension to create a 2D layout
# of your model for laser cutting, CNC milling, etc. that can be exported to a
# SVG or other vector file.
#
# License: The MIT License (MIT)
# @author Alissa Huskey
# @see http://github.com/alissa-huskey/sketchup-vectorize Github Repo
#
# rubocop:disable Style/RedundantFileExtensionInRequire

require "sketchup.rb"
require "extensions.rb"
require_relative "vectorize/version"

module Vectorize
  unless file_loaded?(__FILE__) || $VECTORIZE_UNLOADED   # rubocop:disable Style/GlobalVars
    plugin = SketchupExtension.new(
      "Vectorize",
      File.join("vectorize", "plugin.rb")
    )

    plugin.description = "Turn your 3D model into 2D vector graphics."
    plugin.version     = Vectorize::VERSION
    plugin.copyright   = "Alissa Huskey © 2023"
    plugin.creator     = "Alissa Huskey"
    Sketchup.register_extension(plugin, true)
    file_loaded(__FILE__)
  end
end
