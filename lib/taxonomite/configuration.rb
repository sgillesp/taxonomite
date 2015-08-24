# configuration.rb

module Taxonomite

    ##
    # functionality to provide access to configuration options
    class << self
        attr_writer :configiration
    end

    def self.config
        @configuration ||= Taxonomite::Configuration.new
    end

    def self.configure
        yield(config)
    end

    def self.reset
        @configuration = Taxonomite::Configuration.new
    end

    ##
    # The configuration class for Taxonomite gem. All classes which are configured via
    # this mechanism should extend Taxonomite::Configured (below).
    class Configuration
    
      # future versions may extend to using different tree models
      # - for now uses a custom tree model (:self)
      attr_accessor   :use_tree_model
      # whether to require both up/down taxonomy criteria to be satisfied, by default
      attr_accessor   :default_taxonomy_require_both

    protected
        ##
        # initialize object variables to defaults
        def initialize
            @use_tree_model = :self
            @default_taxonomy_require_both = true
        end
    end
end
