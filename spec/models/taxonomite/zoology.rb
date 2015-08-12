
require 'taxonomite/entity'

module Taxonomite
  class Kingdom < Taxonomite::Node

    protected
    def get_entity_type
        'Kingdom'
    end

    def valid_parent_types
      'Taxonomy'
    end

  end   # class Kingdom

  class Phylum < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'Phylum'
    end

    def valid_parent_types
      'Kingdom'
    end
  end

  class Class < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'Class'
    end

    def valid_parent_types
      'Phylum'
    end
  end

  class Order < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'Order'
    end

    def valid_parent_types
      'Class'
    end
  end

  class Family < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'Family'
    end

    def valid_parent_types
      'Order'
    end
  end

  class Genus < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'Genus'
    end

    def valid_parent_types
      'Family'
    end
  end

  class Species < ::Taxonomite::Node

    def countme
      return 1
    end

    protected
    def get_entity_type
        return 'Species'
    end

    def valid_parent_types
      'Genus'
    end
  end

  class BeingRep
    include Mongoid::Document
    include Taxonomite::Entity

    field :name, type: String         # name of this particular object

    protected
    # overload this to create a specific taxonomy node (i.e. species)
    def create_taxonomy_node
      Taxonomite::Species.new(name: self.name)
    end
  end

  class GenusRep
    include Mongoid::Document
    include Taxonomite::Entity

    field :name, type: String   # name of this genus representation

    protected
      def create_taxonomy_node
        Taxonomite::Genus.new(name: self.name)
      end
  end

end # module Taxonomite
