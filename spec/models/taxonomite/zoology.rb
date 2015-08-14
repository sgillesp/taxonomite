
require 'taxonomite/entity'
require 'taxonomite/taxonomy'

module Taxonomite
  class Kingdom < Taxonomite::Node

    protected
    def get_entity_type
        'kingdom'
    end

    def valid_parent_types
      'taxonomy'
    end

  end   # class Kingdom

  class Phylum < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'phylum'
    end

    def valid_parent_types
      'kingdom'
    end
  end

  class Class < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'class'
    end

    def valid_parent_types
      'phylum'
    end
  end

  class Order < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'order'
    end

    def valid_parent_types
      'class'
    end
  end

  class Family < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'family'
    end

    def valid_parent_types
      'order'
    end
  end

  class Genus < ::Taxonomite::Node

    protected
    def get_entity_type
        return 'genus'
    end

    def valid_parent_types
      'family'
    end
  end

  class Species < ::Taxonomite::Node

    def countme
      return 1
    end

    protected
    def get_entity_type
        return 'species'
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

  class BiologyTaxonomy < Taxonomite::Taxonomy
    protected
    def initial_hash
      { 'kingdom' => 'phylum', 'phylum' => 'class', 'class' => 'order',
        'order' => 'family', 'family' => 'genus', 'genus' => 'species' }
    end
  end

end # module Taxonomite
