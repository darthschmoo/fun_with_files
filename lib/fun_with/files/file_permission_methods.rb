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
      
      def chmod( mode, options )
        FileUtils.chmod( mode, self, options = {} )
      end
    end
  end
end