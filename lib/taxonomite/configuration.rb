# taxonomite_configuration.rb
#   hold configuration parameters for the library
#

module Taxonomite

    ##
    # Allows the class to be configured on its very own, such that it
    # creates its own @configuration class object. Thus if ClassB inherited
    # from ClassA and ClassA extends Configurable, then both could have their own
    # configuration options? Any class that extends this must declare a
    # create_configuration class method.
    module Configurable
      class << self
        attr_writer :configuration
      end

      def config
        @configuration ||= create_configuration
      end

      def configure
        yield(config)
      end

      def reset
        @configuration = create_configuration
      end
    end


    ##
    # The configuration class for Taxonomite gem. All classes which are configured via
    # this mechanism should extend Taxonomite::Configured (below).
    class Configuration
      extend Taxonomite::Configurable

      def self.create_configuration
        Taxonomite::Configuration.new
      end

      # future versions may extend to using different tree models
      # - for now uses a custom tree model (:self)
      attr_accessor   :use_tree_model
      attr_accessor   :default_taxonomy_require_both

    protected
        ##
        # initialize object variables to defaults
        def initialize
            @use_tree_model = :self
            @default_taxonomy_require_both = true
        end
    end


    ##
    # All classes which are configured using Taxonomite::Configuration should
    # extend this module, such that they can access the configuration via their
    # own class methods (i.e. ClassA.config.option)
    module ConfiguredGlobally
      def config
        Taxonomite::Configuration.config
      end

      def reset
        Taxonomite::Configuration.reset
      end
    end
end
