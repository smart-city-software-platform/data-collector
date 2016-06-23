class String

  def is_float?
    true if Float(self) rescue false
  end

end