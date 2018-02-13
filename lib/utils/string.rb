require 'active_support/inflector'

class String
  def is_plural?
    self == self.pluralize
  end
  
  def as_enum_lines
    self.gsub(/\s([\d]{2,}\.[\D])/, "\\\n\\1")
  end
end