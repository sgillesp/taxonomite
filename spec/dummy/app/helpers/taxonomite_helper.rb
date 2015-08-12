module TaxonomiteHelper

    def recurs_taxons(nodes)
        nodes.each do |n|
            render partial: 'taxon', locals: { node: n }
        end
    end

end
