require_relative '../assembly'

module Vectorize
  module SketchupMixins
    # Namespace for mixins to the Sketchup::Group class.
    #
    module Group
      include Vectorize::Assembly
    end
  end
end
