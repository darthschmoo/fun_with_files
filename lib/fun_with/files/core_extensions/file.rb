module FunWith
  module Files
    module CoreExtensions
      module File
        def fwf_filepath( *args )
          FunWith::Files::FilePath.new( self.path, *args )
        end
        
        # I'm not sure this is the most intuitive meaning, but it seems better than
        # delegating to Object.
        def fwf_blank?
          ! self.fwf_filepath.exist?
        end
      end
    end
  end
end