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
        xdg_get('CONFIG').fwf_filepath.join( *args )
      end
      
      def data_dir( *args )
        xdg_get('DATA').fwf_filepath.join( *args )
      end
      
      def cache_dir( *args )
        xdg_get('CACHE_HOME').fwf_filepath.join( *args )
      end
      
      def xdg_get( str )
        if XDG.respond_to?( :"[]" )
          XDG[str]
        else
          case str
          when "CONFIG"
            XDG::Environment.new.config_home
          when "DATA"
            XDG::Environment.new.data_home
          when "CACHE_HOME"
            XDG::Environment.new.cache_home
          else
            raise "Not sure what to do with XDG:#{str}"
          end
        end
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