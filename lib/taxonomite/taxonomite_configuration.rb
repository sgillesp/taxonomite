# taxonomite_configuration.rb
#   hold configuration parameters for the library
#

module Taxonomite
    class Configuration
        # future versions may extend to using different tree models
        # - for now uses a custom tree model (:self)
        attr_accessor   :use_tree_model

    protected
        # initialize
        def initialize
            @use_tree_model = :self
        end
    end
end
