# taxonomite/creator.rb

require 'taxonomite/configuration'
require 'taxonomite/taxonomy'
require 'active_support/concern'


module Taxonomite

  ##
  # Mix-in which allows for enforcing an creating a particular taxonomy.
  module Creator
    extend ActiveSupport::Concern

    included do
      # has_one :taxonomy, as: :owner, class_name: 'Taxonomite::Taxonomy'

      class_eval "def base_class; ::#{self.name}; end"
    end

    ##
    # is parent
    def node_hash_up (n)
    end

    ##
    #
    def is_parent? (node, taxonomy, obj_value)
      if
    end

    ##
    # find the parent of an object (obj) within a Taxonomy
    # using root (if passed) as the root of the taxonomy applied.
    # @param [Taxonomite::Taxonomy] taxonomy the taxonomy to use
    # @param [Taxonomite::Node] obj_tax hash
    # @param [Taxonomite::Node] root the root of the taxonomy into which to assign the Object
    # @return [Taxonomite::Node] the to which the object was assigned
    def find_parent_down (taxonomy, obj_tax, root = nil)
    end

    ##
    # assign an object (obj) to the appropriate parent within a Taxonomy
    # using root (if passed) as the root of the taxonomy applied.
    # @param [Taxonomite::Taxonomy] taxonomy the taxonomy to use
    # @param [Taxonomite::Node] obj the object to assign to the appropriate taxonomy
    # @param [Taxonomite::Node] root the root of the taxonomy into which to assign the Object
    # @return [Taxonomite::Node] the to which the object was assigned
    def assign (taxonomy, obj, root = nil)
    end

  end # module creator

end # module Taxonomite
