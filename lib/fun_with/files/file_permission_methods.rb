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
      
      def chmod( mode, opts = {} )
        FileUtils.chmod( mode, self, narrow_options( opts, FileUtils::OPT_TABLE["chmod"] ) )
      end
    end
  end
end