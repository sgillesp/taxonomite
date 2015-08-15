require 'taxonomite/taxonomite_configuration'
require 'taxonomite/tree'

module Taxonomite
  ##
  # Class which enforces a particular hierarchy among objects.
  class Taxonomy
    include Mongoid::Document

    # ? whether this needs to be stored in the database or not, as most
    # of the time would be instanciated by an application
    field :down_taxonomy, type: Hash, default: ->{ Hash.new("") }
    field :up_taxonomy, type: Hash, default: ->{ Hash.new("") }

    ##
    # determine whether the parent is a valid parent for the child. If no
    # taxonomy is defined (i.e. the hashes are empty) then default is to return
    # true.
    # @param [Taxonomite::Node] parent the proposed parent node
    # @param [Taxonomite::Node] child the proposed child node
    # @return [Boolean] whether the child appropriate for the parent, default true
    def is_valid_relation?(parent, child)
      [self.down_taxonomy[parent.entity_type]].map { |t| return true if [child.entity_type, "*"].include?(t) }
      [self.up_taxonomy[child.entity_type]].map { |t| return true if [parent.entity_type, "*"].include?(t) }
      false
    end

    ##
    # access the appropriate parent entity_types for a particular child or child entity_type
    # @param [Taxonomy::Node, String] child the child object or entity_type string
    # @return [Array] an array of strings which are the valid parent types for the child
    def valid_parent_types(child)
      # could be a node object, or maybe a string
      str = child.respond_to?(:entity_type) ? child.entity_type : child
      self.up_taxonomy[str]
    end

    ##
    # access the appropriate child entity_types for a particular parent or parent entity_type
    # @param [Taxonomy::Node, String] parent the parent object or entity_type string
    # @return [Array] an array of strings which are the valid child types for the child
    def valid_child_types(parent)
      # could be a node object, or maybe a string
      str = parent.respond_to?(:entity_type) ? parent.entity_type : child
      self.down_taxonomy[str]
    end

    # ##
    # # Is this the direct owner of the node passed. This allows for auto-organizing
    # # hierarchies. Sublcasses should override this method. Defaults to false - hence
    # # no structure.
    # # @param [Taxonomite::Node] node node in question
    # # @return [Boolean] whether self should directly own node as a child, default is false
    # def contains?(node)
    #   false
    # end

    ##
    # Find the direct owner of a node within the tree. Returns nil if no direct
    # owner exists within the tree starting at root self. This works down the
    # tree (rather than up.) If root is nil it simply trys all of the Node objects
    # which match the appropriate parent entity_type for node. The default simply
    # finds the first available valid parent depending upon the search method employed.
    # @param [Taxonomite::Node] node the node to evaluate
    # @param [Taxonomite::Node] root the root of the tree to evaluate; if nil will search for the parents of the node first
    # @return [Taxonomite::Node] the appropriate node or nil if none found
    def find_owner(node, root = nil)
      valid_parent_types(node).presence.each do |t|
        getallnodes = lambda { |v| v == '*' ? Taxonomite::Node.find() : Taxonomite::Node.find_by(:entity_type => t) }
        getrootnodes = lambda { |v| v == '*' ? root.self_and_descendants : root.self_and_descendants.find_by(:entity_type => t) }
        ( root.nil? ? getallnodes.call(t) : getrootnodes.call(t) ).each { |n| return n if is_valid_relation(n,node) }
      end
      nil
    end

    ##
    # see if this node belongs directly under a particular parent; this allows for
    # assignment within a hierarchy. Subclasses should override to provide better
    # functionality. Default behavior asks the node if it contains(self).
    # @param [Taxonomite::Node] child the node to evaluate
    # @param [Taxonomite::Parent] parent the parent node to evaluate for the child
    def belongs_under?(parent, child)
      self.find_owner(child, parent) != nil
    end

    # ##
    # # see if this node belongs directly to another node (i.e. would appropriately)
    # # be added as a child of the node. Default returns false. Convention to get
    # # self-organizing hierarchy to work is for belongs_under to return true when
    # # belongs_directly_to is true as well. Default behaviour is to ask the node if
    # # it directly_contains(self).
    # # @param [Taxonomite::Node] node to evaluate
    # # @return [Boolean] whether node contains this object (self)
    # def belongs_directly_to(node)
    #   node.contains?(self)
    # end

    ##
    # try to add a child to a parent, with validation by this Taxonomy
    # @param [Taxonomite::Node] parent the parent node
    # @param [Taxonomite::Node] child the child node
    def add(parent, child)
      raise InvalidChild::create(parent,child) unless self.is_valid_relation?(parent, child)
      parent.add_child(child)
    end

    protected

    # ##
    # # return the default initial hash for this object, default is empty.
    # # Subclasses should override to provide a default hash. A hierarchy could
    # # be createed with this method alone.
    # # @return [Hash] the default (initialized) taxonomy_hash values
    # def initial_hash
    #   {}
    # end

  end   # class Taxonomy
end # module Taxonomite
