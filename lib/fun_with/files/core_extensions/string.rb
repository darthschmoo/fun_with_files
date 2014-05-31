class String
  def fwf_blank?
    self.strip.length == 0
  end
  
  def fwf_filepath( *args )
    FunWith::Files::FilePath.new( self, *args )
  end
end