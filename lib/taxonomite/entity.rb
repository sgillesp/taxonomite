# entity.rb

require 'active_support/concern'

module Taxonomite
  module Entity
    extend ActiveSupport::Concern

    included do
      has_one :taxonomy_node, class_name: 'Taxonomite::Node', as: :owner, validate: true
      before_save :do_setup

      class_eval "def base_class; ::#{self.name}; end"
    end

    def get_taxonomy_node
      if (self.taxonomy_node == nil)
        self.taxonomy_node = self.create_taxonomy_node
      end
      self.taxonomy_node
    end

    protected
      # classes overload to create the appropriate taxonomy_node
      # def create_taxonomy_node
      #   Taxonomite::Node.new(name: self.name)
      # end

    private
      # subclasses should overload create_taxonomy_node to create the appropriate Place object and set it up
      def do_setup
        if (self.taxonomy_node == nil)
          self.taxonomy_node = self.respond_to?(:create_taxonomy_node) ? self.create_taxonomy_node : Taxonomite::Node.new(name: self.name)
          self.taxonomy_node.owner = self
        end
      end

  end # module Location
end # module Places
