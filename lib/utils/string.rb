require 'active_support/inflector'

class String
  def is_plural?
    self == self.pluralize
  end

  def as_enum_lines
    self.gsub(/\s([\d]{2,}\.[\D])/, "\n\\1")
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
