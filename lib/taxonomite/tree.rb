# taxonomite_tree.rb

require 'active_support/concern'
require 'taxonomite/exceptions'

module Taxonomite
  module Tree
    extend ActiveSupport::Concern

    # this is what will be included in the class that uses this
    #
    included do
      has_many :children, :class_name => self.name, :inverse_of => :parent, :before_add => :validate_child!
      belongs_to :parent, :class_name => self.name, :inverse_of => :children

      # this allows for faster database searchign when adding/checking validity
      # !! not implemented  field :parent_ids, :type => Array, :default => []

      class_eval "def base_class; ::#{self.name}; end"
    end

    module ClassMethods
      # find all roots for this tree (Mongoid query)
      def roots
        where(:parent_id => nil)
      end

      # find all leaves fro this tree (Mongoid query)
      def leaves
        where(:_id.nin => only(:parent_id).collect(&:parent_id))
      end
    end

    # is this a root node?
    def root?
      self.parent == nil
    end

    # is this a leaf?
    def leaf?
      self.children.empty?
    end

    # find the root of this node
    def root
      self.root? ? self : self.parent.root
    end

    # is the object an ancestor of nd?
    def is_ancestor?(nd)
      self.root? ? false : (self.parent == nd || self.parent.is_ancestor?(nd))
    end

    # is this an ancestor of another node?
    def ancestor_of?(nd)
      nd.is_ancestor?(self)
    end

    # is this a descendant of nd?
    def descendant_of?(nd)
      (self == nd) ? true : is_ancestor?(nd)
    end

    # return a chainable Mongoid criteria to get all descendants
    def descendants
      doc = Array.new
      children.each do |c|
        doc += [c] + c.descendants
      end
      return doc
    end

    # return a chainable Mongoid criteria to get self + all descendants
    def self_and_descendants
      [self] + self.descendants
    end

    # nullifies all children's parent id (cuts link)
    def nullify_children
      children.each do |c|
        c.parent = nil
        c.save
      end
    end

    # delete children; this *removes all of the children fromt he data base (and ensuing)
    def destroy_children
      children.destroy_all
    end

    # move all children to the parent node
    def move_children_to_parent
      children.each do |c|
        self.parent.children << c
        c.parent = self.parent  # is this necessary?
      end
    end

    # perform validation on whether this child is an acceptable child or not?
    # the base_class must have a method 'is_valid_child?' to implement domain logic there
    def validate_child!(ch)
      raise InvalidChild "Attempted to add nil child to #{self}" if (ch == nil)
      raise CircularRelation, "Circular relationship adding #{ch} to #{self}" if self.descendant_of?(ch)
      if base_class.method_defined? :is_valid_child?
        self.validate_child(ch)  # this should throw an error if not valid
      end
    end

    # to do - find a way to add a Mongoid criteria to return all of the nodes for this object
    # descendants
    # descendants_and_self
    # ancestors
    # ancestors_and_self

  end # Tree
end # Taxonomite
