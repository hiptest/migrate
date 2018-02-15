require 'active_support/inflector'

class String
  def is_plural?
    self == self.pluralize
  end
  
  def as_enum_lines
    self.gsub(/\s([\d]{2,}\.[\D])/, "\\\n\\1")
  end
  
  def single_quotes_escaped
    self.gsub("'", %q(\\\'))
  end
  
  def double_quotes_escaped
    self.gsub('"', %Q(\\\"))
  end
  
  def single_quotes_replaced
    self.gsub("'", '"')
  end
  
  def double_quotes_replaced
    self.gsub('"', "'")
  end
  
  def html_escaped
    self.gsub(%r{&#\w[\d]{2};}, '')
  end
  
  def tag_escaped
    self.gsub(%r{</?[^>]+?>}, '')
  end
  
  def safe
    self.html_escaped.tag_escaped
  end
end