module FunWith
  module Files
    module StatMethods
      def stat
        File.stat( self )
      end
      
      def inode
        self.stat.ino
      end
    end
  end
end