











module FunWith
  module Files
    module Watchers
      class NodeWatcher
        attr_accessor :path
      
        def set_path( path )
          self.path = path.fwf_filepath
        end
      
        def create_watchers( paths )
          {}.tap do |watchers|
            for path in paths
              watchers[path.fwf_filepath] = Watcher.factory( path )
            end
          end
        end
      
        # sets up an object variable for changes, then clears it and returns
        # the changes.  I got sick of passing the changes hash around.
        def new_changeset( &block )
          @changes = {}
          yield
        
          changes = @changes
          @changes = {}
          changes
        end
      end
    end
  end
end
