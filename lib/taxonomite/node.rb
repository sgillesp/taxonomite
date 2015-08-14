require 'taxonomite/taxonomite_configuration'
require 'taxonomite/tree'
require 'mongoid'

module Taxonomite
  class Node
    extend Taxonomite::ConfiguredGlobally

    # handle configurable options - this is essentially how the tree is stored.
    case Node.config.use_tree_model
      when :self
        include ::Mongoid::Document

        # make this protected such that other objects cannot access
        include Taxonomite::Tree
        protected :children
        protected :parent

        # configure the way the tree behaves
        before_destroy :nullify_children

      else
        raise RuntimeError, 'Invalid option for Node.config.use_tree_model: #{Node.config.use_tree_model}'
    end

    field :name, type: String         # name of this particular object (not really node)
    field :entity_type, type: String, default: ->{ self.get_entity_type }  # type of entity (i.e. state, county, city, etc.)
    field :require_taxonomy, type: Boolean, default: ->{ Node.config.require_taxonomy }

    belongs_to :owner, polymorphic: true # this is the associated object

    # Data collection methods

    ##
    # aggregates the results of calling method m on all leaves of the tree
    # @param [Method] m method to call on owner and pass to children
    # @return [] aggregated values from m on all children
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

    ##
    # typeify name w entity (i.e. 'Washington state' vs. 'Seattle')
    # @return [String] the typeified name
    def typeifiedname
      s = self.name
      s += (" " + self.entity_type.capitalize) if self.includetypeinname?
      return s
    end

    ##
    # determine whether this is a valid parent of the object; subclasses could override
    # to provide other functionality - though the intention is for the hierarchy to be
    # enforced via a Taxonomy object
    # @param [Taxonomite::Node] parent the parent node in question
    # @return [Boolean] default is true
    def is_valid_parent?(parent, taxonomy = nil)
      self.evaluate_parent(parent) && taxonomy.presence.is_valid_relation?(parent, self)
    end

    ##
    # determine whether this is a valid parent of the object; subclasses could override
    # to provide other functionality - though the intention is for the hierarchy to be
    # enforced via a Taxonomy object
    # @param [Taxonomite::Node] child the parent node in question
    # @return [Boolean] default is true
    def is_valid_child?(child, taxonomy = nil)
      evaluate_child(child) && (taxonomy.nil? ? true : taxonomy.is_valid_relation?(self, child))
    end

    ##
    # Is this the direct owner of the node passed. This allows for auto-organizing
    # hierarchies. Sublcasses should override this method. Defaults to false - hence
    # no structure.
    # @param [Taxonomite::Node] node node in question
    # @param [Taxonomite::Taxonomy] taxonomy to use to determine the containment
    # @return [Boolean] whether self should directly own node as a child, default is false
    def contains?(node, taxonomy = nil)
      false
    end

    ##
    # Find the direct owner of a node within the tree. Returns nil if no direct
    # owner exists within the tree starting at root self.
    # @param [Taxonomite::Node] node the node to evaluate
    # @param [Taxonomite::Taxonomy] taxonomy to use to determine the containment
    # @return [Taxonomite::Node] the appropriate node or nil if none found
    def find_owner(node, taxonomy = nil)
      return nil if taxonomy.nil?
      return self if self.should_own?(node,taxonomy)
      if children.present?
        children.each do |c|
            c.find_owner(node, taxonomy).presence.each { |n| return n if !n.nil? }
        end
      end
      return nil
    end

    ##
    # see if this node belongs directly under a particular parent; this allows for
    # assignment within a hierarchy. Subclasses should override to provide better
    # functionality. Default behavior asks the node if it contains(self).
    # @param [Taxonomite::Node] node the node to evaluate
    # @param [Taxonomite::Taxonomy] taxonomy to use to determine the containment
    # @return [Boolean] whether this node should belong under the node
    def belongs_under(node, taxonomy = nil)
      node.find_owner(self, taxonomy) != nil
    end

    ##
    # see if this node belongs directly to another node (i.e. would appropriately)
    # be added as a child of the node. Default returns false. Convention to get
    # self-organizing hierarchy to work is for belongs_under to return true when
    # belongs_directly_to is true as well. Default behaviour is to ask the node if
    # it directly_contains(self).
    # @param [Taxonomite::Node] node the node to evaluate
    # @param [Taxonomite::Taxonomy] taxonomy to use to determine the containment
    # @return [Boolean] whether this node should belong directly under the node
    def belongs_directly_to(node, taxonomy = nil)
      node.contains?(self, taxonomy)
    end

    ##
    # add a child to this object; default is that each parent may have many children;
    # this will validate the child using thetaxonomy object passed in to the field.
    # @param [Taxonomite::Node] child the node to evaluate
    # @param [Taxonomite::Taxonomy] taxonomy to use to validate the hierarchy
    def add_child(child, taxonomy = nil)
      validate_child(child, taxonomy)
      self.children << child
    end

    ##
    # add a parent for this object (default is that each object can have only one
    # parent).
    # this will validate the child using the taxonomy object passed in to the field.
    # @param [Taxonomite::Node] parent the node to evaluate
    # @param [Taxonomite::Taxonomy] taxonomy to use to validate the hierarchy
    def add_parent(parent, taxonomy = nil)
      parent.add_child(self, taxonomy)
    end

    ##
    # provides access to the children of the node. Node that adding and removing
    # children outside the context of the add_child and add_parent methods is
    # discouraged as this will break the hierarchy.
    # @return [Array] the array of children methods
    def children!
      self.children
    end

    ##
    # provides access to the parent of the node. Node that adding and removing
    # children outside the context of the add_child and add_parent methods is
    # discouraged as this will break the hierarchy.
    # @return [Taxonomy::Node] the parent for this node
    def parent!
      self.parent
    end

    protected
        ##
        # include type in the name of this place (i.e. 'Washington state')
        # @return [Boolean]
        def includetypeinname?
          return false
        end

        ##
        # access the entity type for this Object
        # @return [String]
        def get_entity_type
          'Node'
        end

        ##
        # determine whether child is a valid child based upon class evalution
        # (outside of a taxonomy). Default is always true - subclasses should
        # override if validation outside of a separate taxonomy class is desired.
        # @param [Taxonomite::Node] child child to evaluate
        def evaluate_child(child)
          return true
        end

        ##
        # determine whether parent is a valid parent based upon class evalution
        # (outside of a taxonomy). Default is always true - subclasses should
        # override if validation outside of a separate taxonomy class is desired.
        # @param [Taxonomite::Node] parent parent to evaluate
        def evaluate_parent(child)
          return true
        end

    private
      ##
      # determine whether the child is valid for this object; there are two
      # layers to validation 1) provided by this method is_valid_parent? (and subclasses which override
      # is_valid_parent?) and 2) provided by the taxonomy. The latter is skipped
      # if taxonomy is nil (or not passed); however, if validation_requires_taxonomy
      # is set to true for this object, then an exception is thrown if taxonomy is
      # nil.
      # @param [Taxonomite::Node] child the parent to validate
      # @param [Taxonomite::Taxonomy] taxonomy to perform validation, default nil
      # @return [Boolean] whether validation was successful
      def validate_child(child, taxonomy = nil)
        raise InvalidParent, "Cannot add #{ch} as child of #{self.name} (#{self.entity_type})" if child.nil?

        if taxonomy.nil?
          raise NoValidationWithoutTaxonomy, "Cannot validate child without a valid taxonomy, passed #{taxonomy}" if self.require_taxonomy
          raise InvalidChild, "Cannot add #{child.name} (#{child.entity_type}) as child of #{self.name} (#{self.entity_type})" unless is_valid_child?(child, taxonomy)
          false
        else
          raise InvalidChild, "Cannot add #{child.name} (#{child.entity_type}) as child of #{self.name} (#{self.entity_type})" unless is_valid_child?(child, taxonomy)
        end
      end

      ##
      # determine whether the parent is valid for this object. See description of
      # validate_child for more detail. This method calls validate_child to perform
      # the actual validation.
      # @param [Taxonomite::Node] parent the parent to validate
      # @param [Taxonomite::Taxonomy] taxonomy to perform validation, default nil
      # @return [Boolean] whether validation was successful
      def validate_parent(parent, taxonomy = nil)
        raise InvalidParent, "Cannot add #{self.name} (#{self.entity_type}) as child of #{parent}" if parent.nil?
        raise InvalidParent, "Cannot add #{self.name} (#{self.entity_type}) as child of #{parent.name} (#{parent.entity_type})" unless evaluate_parent(parent)
        parent.validate_child(self, taxonomy)
      end

  end   # class Node
end # module Taxonomite
