require 'taxonomite/taxonomite_configuration'
require 'taxonomite/tree'
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
    extend Taxonomite::ConfiguredGlobally

    # handle configurable options - this is essentially how the tree is stored.
    case Node.config.use_tree_model
      when :self
        include ::Mongoid::Document

        # make this protected such that other objects cannot access
        include Taxonomite::Tree

        # configure the way the tree behaves
        before_destroy :nullify_children

      else
        raise RuntimeError, 'Invalid option for Node.config.use_tree_model: #{Node.config.use_tree_model}'
    end

    field :name, type: String         # name of this particular object (not really node)
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
    # typeify name w entity (i.e. 'Washington state' vs. 'Seattle')
    # @return [String] the typeified name
    def typeifiedname
      s = self.name
      s += (" " + self.entity_type.capitalize) if self.includetypeinname?
      return s
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
