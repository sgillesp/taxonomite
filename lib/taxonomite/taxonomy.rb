require 'taxonomite/taxonomite_configuration'
require 'taxonomite/tree'

module Taxonomite
  ##
  # Class which enforces a particular hierarchy among objects.
  class Taxonomy
    # ? whether this needs to be stored in the database or not, as most
    # of the time would be instanciated by an application
    field :taxonomy, type: Hash   # the underlying hash

    ##
    # determine whether the parent is a valid parent for the child. If no
    # taxonomy is defined (i.e. the hash is empty) then default is to return
    # true.
    # @param [Taxonomite::Node] parent the proposed parent node
    # @param [Taxonomite::Node] child the proposed child node
    # @return [Boolean] whether the child appropriate for the parent, default true
    def is_valid_relation?(parent, child)
      self.taxonomy.present? ? self.taxonomy[parent.entity_type].find(child.entity_type) : true
    end

    ##
    # access the appropriate parent entity_types for a particular child or child entity_type
    # @param [Taxonomy::Node, String] child the child object or entity_type string
    # @return [Array] an array of strings which are the valid parent types for the child
    def valid_parent_types(child)
      # could be a node object, or maybe a string
      str = child.respond_to?(:entity_type) ? child.entity_type : child
      # statement to find all hash results containing child
    end

    ##
    # access the appropriate child entity_types for a particular parent or parent entity_type
    # @param [Taxonomy::Node, String] parent the parent object or entity_type string
    # @return [Array] an array of strings which are the valid child types for the child
    def valid_child_types(parent)
      # could be a node object, or maybe a string
      str = parent.respond_to?(:entity_type) ? parent.entity_type : child
      self.taxonomy[str]
    end

    ##
    # Is this the direct owner of the node passed. This allows for auto-organizing
    # hierarchies. Sublcasses should override this method. Defaults to false - hence
    # no structure.
    # @param [Taxonomite::Node] node node in question
    # @return [Boolean] whether self should directly own node as a child, default is false
    def contains?(node)
      false
    end

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
      if root != nil
        # try to find the appropriate parent node moving down the tree
        return root if self.is_valid_relation?(root, node)
        for root.children.each do |c| unless !root.children.present?
          do find_owner_down(node) { |o| return o if o != nil }
        end
      else
        # try to find the nodes with parent types that are valid for this object
        if p = valid_parent_types(node)
          p.each do |t|
            # check if an asterisk (in which case )
            t == '*' ? Taxonomite::Node.find().each : Taxonomite::Node.find_by(:entity_type => t).each do |n|
              return n if is_valid_relation(n,node)
            end
          end
        end

      end
      nil
    end

    ##
    # see if this node belongs directly under a particular parent; this allows for
    # assignment within a hierarchy. Subclasses should override to provide better
    # functionality. Default behavior asks the node if it contains(self).
    def belongs_under(node)
      node.find_owner(self) != nil
    end

    ##
    # see if this node belongs directly to another node (i.e. would appropriately)
    # be added as a child of the node. Default returns false. Convention to get
    # self-organizing hierarchy to work is for belongs_under to return true when
    # belongs_directly_to is true as well. Default behaviour is to ask the node if
    # it directly_contains(self).
    # @param [Taxonomite::Node] node to evaluate
    def belongs_directly_to(node)
      node.contains?(self)
    end

    protected
        def validate_relation(parent, child)
          raise InvalidChild, "Cannot add #{child.name} (#{child.entity_type}) as child of #{parent.name} (#{parent.entity_type})" if !is_valid_relation?(parent, child)
        end

  end   # class Taxonomy
end # module Taxonomite