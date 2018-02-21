require 'active_support/inflector'

class String
  def is_plural?
    self == self.pluralize
  end

  def as_enum_lines
    self.gsub(/\s([\d]{2,}\.[\D])/, "\n\\1")
  end
  
  def uncapitalize 
    self[0, 1].downcase + self[1..-1]
  end
  
  def camelize
    self.split("_").each.with_index {|s, i| s.capitalize! if i > 0 }.join("")
  end
  
  def underscore
    self.gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      .gsub(/([a-z\d])([A-Z])/,'\1_\2')
      .tr("-", "_")
      .downcase
  end

  def single_quotes_escaped
    self.gsub("'", %q(\\\')).gsub('&#x27;', %q(\\\'))
  end

  def double_quotes_escaped
    self.gsub('"', %Q(\\\"))
  end

  def single_quotes_replaced
    self.gsub("'", '"').gsub('&#x27;', '"')
  end

  def double_quotes_replaced
    self.gsub('"', "'")
  end

  def html_escaped
    self.gsub(%r{&#\w[\d]+;}, '')
  end

  def tag_escaped
    self.gsub(%r{</?[^>]+?>}, '').gsub(%r{&lt;/?[^(&gt;)]+?&gt;}, '')
  end

  def safe
    self.tag_escaped.html_escaped
  end
end
