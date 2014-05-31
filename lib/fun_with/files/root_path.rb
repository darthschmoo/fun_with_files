module FunWith
  module Files
    module RootPathExtensions
      def root( *args )
        if args.length > 0
          args.unshift( @root_path )
          FilePath.new( *args )
        else
          FilePath.new( @root_path )
        end
      end
      
      def set_root_path( path )
        @root_path = FunWith::Files::FilePath.new( path )
      end
    end

    class RootPath
      def self.rootify( target, path )
        if target.respond_to?(:root)
          warn( "#{target} already responds to :root, skipping installation" )
          return nil
        end
        
        target.extend( RootPathExtensions )
        target.set_root_path( FilePath.new( path ) )
      end
    end
  end
end