require 'taxonomite/configuration'
require 'mongoid'

module Taxonomite
  ##
  # Class which defines a node within a tree hierarchy. Validation on addition
  # of children and parents does occur in this class to provide for class specific
  # validation in subclasses. That said, enforcing a taxonomy (rules about how the
  # hierarchy is constructed) falls to the Taxonomite::Taxonomy class which is
  # used to join parents and children according to specified rules. Thus, if
  # someone does Obj.children << node -- no special validation will occur, other
  # than that provided within this class or subclasses via is_valid_child? and
  # is_valid_parent?
  #
  class Node

    # handle configurable options - this is essentially how the tree is stored.
    case Taxonomite.config.use_tree_model
      when :self
        include ::Mongoid::Document
        require 'taxonomite/tree'

        # make this protected such that other objects cannot access
        include Taxonomite::Tree

        # configure the way the tree behaves
        before_destroy :nullify_children

      else
        raise RuntimeError, 'Invalid option for Taxonomite.config.use_tree_model: #{Taxonomite.config.use_tree_model}'
    end

    field :entity_type, type: String, default: ->{ self.get_entity_type }  # type of entity (i.e. state, county, city, etc.)
    belongs_to :owner, polymorphic: true # this is the associated object

    ##
    # evaluate a method on the owner of this node (if present). If an owner is
    # not present, then the method is evaluated on this object. In either case
    # a check is made to ensure that the object will respond_to? the method call.
    # If the owner exists but does not respond to the method, then the method is
    # tried on this node object in similar fashion.
    # !!! SHOULD THIS JUST OVERRIDE instance_eval ??
    # @param [Method] m method to call
    # @return [] the result of the method call, or nil if unable to evaluate
    def evaluate(m)
      return self.owner.instance_eval(m) if self.owner != nil && self.owner.respond_to?(m)
      return self.instance_eval(m) if self.respond_to?(m)
      nil
    end

    ##
    # determine whether child is a valid child based upon class evalution
    # (outside of a taxonomy). Default is always true - subclasses should
    # override if validation outside of a separate taxonomy class is desired.
    # @param [Taxonomite::Node] child child to evaluate
    # @return [Boolean] default is true
    def is_valid_child?(child)
      return true
    end

    ##
    # determine whether parent is a valid parent based upon class evalution
    # (outside of a taxonomy). Default is always true - subclasses should
    # override if validation outside of a separate taxonomy class is desired.
    # @param [Taxonomite::Node] parent parent to evaluate
    # @return [Boolean] default is true
    def is_valid_parent?(child)
      return true
    end

    ##
    # add a child to this object; default is that each parent may have many children;
    # this will validate the child using thetaxonomy object passed in to the field.
    # @param [Taxonomite::Node] child the node to evaluate
    def add_child(child)
      self.children << child
    end

    ##
    # add a parent for this object (default is that each object can have only one
    # parent).
    # this will validate the child using the taxonomy object passed in to the field.
    # @param [Taxonomite::Node] parent the node to evaluate
    # @param [Taxonomite::Taxonomy] taxonomy to use to validate the hierarchy
    def add_parent(parent)
      parent.add_child(self)
    end

    ##
    # remove a child from this node.
    # @param [Taxonomite::Node] child node to remove
    def remove_child(child)
      self.children.delete(child)
    end

    ##
    # remove the parent from this node. This should cause a reciprocal removal
    # of self from the parent's children
    def remove_parent
      self.parent.remove_child(self) unless self.parent.nil?
    end

    ##
    # is this node equal to another node
    # @param n node to compare
    # @return [Boolean] are these nodes equal
    def equal_to_node? (n)
      self.value == n.value
    end

    ##
    # is this node equal to another node
    # @param val value to compare to, this should be a particular value type
    # @return [Boolean] are these nodes equal
    def equal_to? (val)
      self.value == val
    end

    ##
    # access a value for this node, default is nil; should be overloaded
    # by subclasses.
    # @return value
    def value
      nil
    end

    ##
    # create a hash of this node in its position in the tree, looking
    # backward toward the parents
    # @return [Hash] a hash of key,value pairs of entity_type, value
    def hash_up
      rv = Hash.new
      self.self_and_ancestors.each do |c|
        rv[c.entity_type] = c.value
      end
      return rv
    end

    protected

        ##
        # access the entity type for this Object
        # @return [String]
        def get_entity_type
          'node'
        end

    private
      ##
      # determine whether the child is valid for this object; there are two
      # layers to validation 1) provided by this method is_valid_parent? (and subclasses which override
      # is_valid_parent?).
      # @param [Taxonomite::Node] child the parent to validate
      # @return [Boolean] whether validation was successful
      def validate_child(child)
        raise InvalidParent.create(self, child) unless (!child.nil? && is_valid_child?(child))
        true
      end

      ##
      # determine whether the parent is valid for this object. See description of
      # validate_child for more detail. This method calls validate_child to perform
      # the actual validation.
      # @param [Taxonomite::Node] parent the parent to validate
      # @return [Boolean] whether validation was successful
      def validate_parent(parent)
        raise InvalidParent.create(parent, self) unless (!parent.nil? && is_valid_parent?(parent))
        parent.validate_child(self)
      end

  end   # class Node
end # module Taxonomite
