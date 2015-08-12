module TaxonomiteHelper

    def recurs_nodes(nodes)
        nodes.each do |n|
            render partial: 'node', locals: { node: n }
        end
    end

end
