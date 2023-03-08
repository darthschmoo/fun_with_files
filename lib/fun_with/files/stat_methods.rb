module FunWith
  module Files
    module StatMethods
      def stat
        File.stat( self )
      end
      
      def inode
        self.stat.ino
      end
      
      # def older_than?( time, &block )
      # end
      #
      # def newer_than?( time, &block )
      # end
      #
      # def bigger_than?( sz, units = :B, &block )
      # end
      #
      # def smaller_than?( sz, units = :B, &block )
      # end
      #
      # def modified_before?( time, &block )
      # end
      #
      # def modified_since?( time, &block )
      # end
      
      
    end
  end
end