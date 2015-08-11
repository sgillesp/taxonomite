$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "taxonomite/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "taxonomite"
  s.version     = Taxonomite::VERSION
  s.authors     = ["sgillesp"]
  s.email       = ["masterofratios@gmail.com"]
  s.homepage    = "http://github.com/sgillesp/places"
  s.summary     = "Manages objects which are classified within a taxonomy, and enforces a hierarchical tree structure. Works with MongoDB."
  s.description = "Manages objects which are classified within a taxonomy, and enforces a hierarchical tree structure. Works with MongoDB currently - may try to abstract the database layer with later versions."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails" #, "~> 4.2.3"
  s.add_dependency "mongodb"
  s.add_dependency "moped"
  s.add_dependency "mongoid"
  s.add_dependency "bson_ext"

  s.add_development_dependency "rspec-rails", "3.3.2"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "faker"
  s.add_development_dependency "better_errors"
  s.add_development_dependency "binding_of_caller"
end
