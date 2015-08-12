require 'taxonomite/taxonomite_configuration'
require 'taxonomite/tree'

module Taxonomite
  class Node
    # Class declarations
    #
    # configuration
    #
    # !! note that configuration is class-wide, rather than on an
    #    instance-instance value; this could be changed, for example if
    #    two simultaneous persistence models for the place were desired
    #
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

    def self.primary_key
      "_id"
    end

    case Node.config.use_tree_model
    when :self
      include ::Mongoid::Document
      include Taxonomite::Tree

      # configure the way the tree behaves
      before_destroy :nullify_children
    else
      raise RuntimeError, 'Invalid option for Node.config.use_tree_model: #{Node.config.use_tree_model}'
    end

    field :name, type: String         # name of this particular object (not really node)
    field :description, type: String  # description of this item
    field :entity_type, type: String, default: ->{ self.get_entity_type }  # type of entity (i.e. state, county, city, etc.)

    belongs_to :owner, polymorphic: true # this is the associated object

    ## Data collection methods

    # aggregates the results of calling method m on all leaves of the tree and returns that
    def aggregate_leaves(m)
      if self.leaf?
        return self.owner.instance_eval(m) if self.owner != nil && self.owner.respond_to?(m)
        return self.instance_eval(m) if self.respond_to?(m)
        return 0
      else
        res = 0
        self.children.each do |c|
          res = res + c.aggregate_leaves(m)
        end
        return res
      end
    end

    ## Typeification methods

    # typeify name w entity (i.e. 'Washington state' vs. 'Seattle')
    def typeifiedname
      s = self.name
      s += (" " + self.entity_type.capitalize) if self.includetypeinname?
      return s
    end

    # subclasses should override to make sure the parent is appropriate for this child
    # !! could move this to the tree structure
    def is_valid_parent?(pa)
        # !! need to figure out how to do this with regexp
        unless self.invalid_parent_types.include?(pa.entity_type)
          s = self.valid_parent_types
          if s.include?('*')
            return true
          else
            return s.include?(pa.entity_type)
          end
        else
          return false
        end
    end

    # check for validity, with adding error checking this would be the appropriate
    # place to add exceptions, etc. (to allow recovery);
    # !! could move this to the tree structure
    def is_valid_child?(ch)
        # !! need to figure out how to do this with regexp
        unless self.invalid_child_types.include?(ch.entity_type)
          s = self.valid_child_types
          if s.include?('*') || s.include?(ch.entity_type)
            return ch.is_valid_parent?(self)
          else
            return false
          end
        else
          return false
        end
    end

    # default parent types (subclasses should override as needed) - default specifies any
    def valid_parent_types
      '*'
    end

    # default child types (subclasses should override as needed) - default specifies any
    def valid_child_types
      '*'
    end

    # default invalid child types
    def invalid_child_types
      ""
    end

    # default invalid parent types
    def invalid_parent_types
      ""
    end

    # don't want to index off of place name? - could have multiple entries w. similar names
    # create an index off of the place name, alone; will later create on off of the
    # geo locations *additionally*
    # index({ place_name: 1 }, { unique: false, name: "name_index"})

    # ** would like to hide these interfaces in a private/protected manner, not clear
    # ** how to do this in Ruby - doesn't have 'const' access similar to c++, etc.
    protected

        # include type in the name of this place (i.e. 'Washington state')
        def includetypeinname?
          return false
        end

        # set the entity type (each subclass should override)
        def get_entity_type
          'Node'
        end

        def validate_child(ch)
          raise InvalidChild, "Cannot add #{ch.name} (#{ch.entity_type}) as child of #{self.name} (#{self.entity_type})" if !is_valid_child?(ch)
        end

        def validate_parent(pa)
          raise InvalidParent, "Cannot add #{pa.name} (#{pa.enity_type}) as parent of #{self.name} (#{self.entity_type})" if !is_valid_parent?(pa)
        end

  end   # class Node
end # module Taxonomite
