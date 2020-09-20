module FunWith
  module Files
    module Watchers
      # Watches a path where nothing currently exists, and reports a change if
      # something appears there.   
      class MissingWatcher < NodeWatcher
        def initialize( path )
          set_path( path )
        end
      
        # The fact that the watcher now needs to be replaced with a File/DirectoryWatcher
        # must be handled elsewhere.
        def update
          self.path.exist? ? {self.path => :created } : {}
        end
      
        def all_paths
          []
        end
      end
    end
  end
end