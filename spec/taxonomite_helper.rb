require 'taxonomite/taxonomite_configuration.rb'

Taxonomite::Node.configure do |config|
    config.use_tree_model = :self
end
