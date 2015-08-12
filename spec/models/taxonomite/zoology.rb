
module Taxonomite
  class Kingdom < Taxonomite::Taxon

    protected
    def get_entity_type
        'Kingdom'
    end

    def valid_parent_types
      'Taxonomy'
    end

  end   # class Kingdom

  class Phylum < ::Taxonomite::Taxon

    protected
    def get_entity_type
        return 'Phylum'
    end

    def valid_parent_types
      'Kingdom'
    end
  end

  class Class < ::Taxonomite::Taxon

    protected
    def get_entity_type
        return 'Class'
    end

    def valid_parent_types
      'Phylum'
    end
  end

  class Order < ::Taxonomite::Taxon

    protected
    def get_entity_type
        return 'Order'
    end

    def valid_parent_types
      'Class'
    end
  end

  class Family < ::Taxonomite::Taxon

    protected
    def get_entity_type
        return 'Family'
    end

    def valid_parent_types
      'Order'
    end
  end

  class Genus < ::Taxonomite::Taxon

    protected
    def get_entity_type
        return 'Genus'
    end

    def valid_parent_types
      'Family'
    end
  end

  class Species < ::Taxonomite::Taxon

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

end # module Taxonomite
