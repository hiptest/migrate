require 'active_support/inflector'

class String
  def is_plural?
    self == self.pluralize
  end
end