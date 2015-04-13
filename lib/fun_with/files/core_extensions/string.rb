module FunWith
  module Files
    module CoreExtensions
      module String
        def fwf_blank?
          self.strip.length == 0
        end
  
        def fwf_filepath( *args )
          FunWith::Files::FilePath.new( self, *args )
        end
  
        def to_pathname
          Pathname.new( self )
        end
      end
    end
  end
end