# taxonomite/crawler.rb

require 'taxonomite/configuration'
require 'taxonomite/node'
require 'taxonomite/taxonomy'


module Taxonomite

  ##
  # Class which will traverse a taxonomy tree and find a particular pattern
  # of nodes within the tree.
  class Crawler
    # extend ActiveSupport::Concern
    #
    # included do
    #   # has_one :taxonomy, as: :owner, class_name: 'Taxonomite::Taxonomy'
    #
    #   class_eval "def base_class; ::#{self.name}; end"
    # end


    ##
    #
    def is_parent? (node, taxonomy, obj_value)
    end

    ##
    # find the parent of an object (obj_tax) within a tree
    # using root as the basis of the tree. An alternative method (perhaps a
    # faster means of searching) would be to find the lowest entity_type within
    # a particular taxonomy.
    # @param [Hash] obj_tax
    # @param [Taxonomite::Node] root the root of the tree to search
    # @return [Taxonomite::Node] the appropriate parent for the object
    def find_parent_down (n, root, taxonomy = nil)
      h = self.node_hash_up(n)
      return self.find_parent_down_by_hash(h,root)
    end

    ##
    # return the hash of the object;
    # @return [Hash] the hash of the entity_type/node
    def node_hash_up (n)
      h = Hash.new
      n.ancestors().flatten.each do |a|
          h[a.entity_type] = a.to_s
      end
      return h
    end

    ##
    # find the parent of an object (obj) within a Taxonomy
    # using root (if passed) as the root of the taxonomy applied.
    # @param [Taxonomite::Taxonomy] taxonomy the taxonomy to use
    # @param [Taxonomite::Node] obj_tax hash
    # @param [Taxonomite::Node] root the root of the taxonomy into which to assign the Object
    # @return [Taxonomite::Node] the to which the object was assigned
    # def find_parent_down (taxonomy, obj_tax, root = nil)
    #   str = obj_tax[root.entity_type]
    # end

    ##
    # assign an object (obj) to the appropriate parent within a Taxonomy
    # using root (if passed) as the root of the taxonomy applied.
    # @param [Taxonomite::Taxonomy] taxonomy the taxonomy to use
    # @param [Taxonomite::Node] obj the object to assign to the appropriate taxonomy
    # @param [Taxonomite::Node] root the root of the taxonomy into which to assign the Object
    # @return [Taxonomite::Node] the to which the object was assigned
    def assign (taxonomy, obj, root = nil)
    end

    protected
    ##
    # find the parent of an object described as a hash of entity_type - and
    # some sort of comparable value (such as a name).
    # @param [Hash] obj_tax
    # @param [Taxonomite::Node] root the root of the tree to search
    # @return [Taxonomite::Node] the appropriate parent for the object; nil if not found
    def find_parent_down_by_hash(obj_tax, root)
      hstr = obj_tax[root.entity_type]
      return nil if (hstr.nil? || (hstr != root.to_s))

      if (hstr.nil? || (hstr == root.to_s)) then
        root.children.each do |c|
          tobj = self.find_parent_down_by_hash(obj_tax,c)
          return tobj unless tobj.nil?
        end
        return root
      end
      return nil
    end


  end # module crawler

end # module Taxonomite
