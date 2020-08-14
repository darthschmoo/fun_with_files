module FunWith
  module Files
    # view and change file permissions
    module FilePermissionMethods
      def readable?
        File.readable?( self )
      end
      
      def writable?
        File.writable?( self )
      end
      
      def executable?
        File.executable?( self )
      end
      
      # options:  :noop, :verbose
      def chmod( mode, opts = {} )
        FileUtils.chmod( mode, self, ** Utils::Opts.narrow_options( opts, FileUtils::OPT_TABLE["chmod"] ) )
      end
      
      # options:  :noop, :verbose
      def chown( user, opts = {} )
        FileUtils.chown( user, self, ** Utils::Opts.narrow_options( opts, FileUtils::OPT_TABLE["chown"] ) )
      end
      
      def owner
        uid = File.stat( self ).uid
        Etc.getpwuid( uid ).name
      end
    end
  end
end