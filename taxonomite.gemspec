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
  s.summary     = "Manages objects classified within a taxonomy and enforces a hierarchical tree structure. Persently works only with MongoDB."
  s.description = "Manages objects classified within a taxonomy and enforces a hierarchical tree structure. Works only with MongoDB currently - may try to abstract the database layer with later versions."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", '~> 4.0', '>= 4.0'
  s.add_dependency "mongodb", '~> 0.0.13', '>= 0'
  s.add_dependency "moped", '~> 2.0', '>= 2.0'
  s.add_dependency "mongoid", '~> 4.0.2', '>= 4.0'
  s.add_dependency "bson_ext", '~> 1.5.0', '>= 1.0'

  s.add_development_dependency "rspec-rails", "3.3.2"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "faker"
  s.add_development_dependency "better_errors"
  s.add_development_dependency "binding_of_caller"
end
