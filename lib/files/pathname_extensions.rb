class Pathname
  def fwf_filepath(*args)
    FunWith::Files::FilePath.new( self, *args )
  end
end