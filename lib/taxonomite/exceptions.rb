# taxonomite/exceptions.rb

module Taxonomite

  module CreateClassMethod
    def create(parent, child)
      new("", parent, child)
    end
  end

  class InvalidChild < RuntimeError
    extend CreateClassMethod

    def initialize(msg = "Invalid attempt to add Taxonomite::Node.", parent = nil, child = nil)
      msg = "Cannot add " +
            ( child.nil? ? "nil child" : "#{child.entity_type}" ) +
            " as child of #{parent.entity_type}" unless parent.nil?
      super(msg)
    end
  end

  class InvalidParent < RuntimeError
    extend CreateClassMethod

    def initialize(msg = "Invalid attempt to add Taxonomite::Node.", parent = nil, child = nil)
      unless (parent.nil? && child.nil?)
        msg = "Cannot add " +
              ( child.nil? ? "nil child" : "#{child.entity_type}" ) +
              " as child of #{parent.entity_type}" unless parent.nil?
      end
      super(msg)
    end
  end

  class CircularRelation < RuntimeError
    extend CreateClassMethod

    def initialize(msg = "Circular relation in attempt to add Taxonomite::Node.", parent = nil, child = nil)
      msg = "Circular reference in adding " +
            ( child.nil? ? "nil child" : "#{child.entity_type}" ) +
            " as child of #{parent.entity_type}" unless parent.nil?
      super(msg)
    end
  end

end # taxonomite
