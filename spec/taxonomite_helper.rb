require 'taxonomite/taxonomite_configuration.rb'

Taxonomite::Taxon.configure do |config|
    config.use_tree_model = :self
end
