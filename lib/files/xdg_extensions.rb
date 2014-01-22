module XDG
  class BaseDir
    def fwf_filepath( *args )
      FunWith::Files::FilePath.new( self.to_s, *args )
    end
  end
end