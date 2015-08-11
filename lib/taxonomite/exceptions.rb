# taxonomite/exceptions.rb

module Taxonomite
  class InvalidChild < RuntimeError; end
  class InvalidParent < RuntimeError; end
  class CircularRelation < RuntimeError; end
end # taxonomite
