module FunWith
  module Files
    # view and change file permissions
    module FilePermissionMethods
      def readable?( &block )
        _yield_self_on_success( File.readable?( self ), &block )
      end
      
      def writable?( &block )
        _yield_self_on_success( File.writable?( self ), &block )
      end
      
      def executable?( &block )
        _yield_self_on_success( File.executable?( self ), &block )
      end
      
      # options:  :noop, :verbose
      def chmod( mode, opts = {} )
        FileUtils.chmod( mode, self, ** Utils::Opts.narrow_file_utils_options( opts, :chmod ) )
      end 
      
      # options:  :noop, :verbose
      def chown( user, opts = {} )
        FileUtils.chown( user, self, ** Utils::Opts.narrow_file_utils_options( opts, :chown ) )
      end
      
      def owner
        uid = File.stat( self ).uid
        Etc.getpwuid( uid ).name
      end
    end
  end
end