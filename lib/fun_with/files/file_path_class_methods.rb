module FunWith
  module Files
    module FilePathClassMethods
      # args implicitly joined to cwd
      def cwd( *args )
        Dir.pwd.fwf_filepath.join( *args )
      end
      
      def pwd( *args )
        self.cwd( *args )
      end
      
      def home( *args )
        Dir.home.fwf_filepath.join( *args )
      end
      
      def config_dir( *args )
        XDG['CONFIG'].fwf_filepath.join( *args )
      end
      
      def data_dir( *args )
        XDG['DATA'].fwf_filepath.join( *args )
      end
      
      def cache_dir( *args )
        XDG['CACHE_HOME'].fwf_filepath.join( *args )
      end
      
      # Honestly this is a token attempt at Windows compatibility.
      # This could go wrong all sorts of ways, and hasn't been tested
      # on Windows.  More to the point, when a Windows machine has
      # multiple drives mounted, what do you even call the root?
      def root( *args )
        if self.home =~ /^[a-zA-Z]:/
          self.home.to_s[0..3].fwf_filepath.join( *args )
        else
          "/".fwf_filepath.join( *args )
        end
      end
    end
  end
end