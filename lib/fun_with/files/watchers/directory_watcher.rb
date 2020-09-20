module FunWith
  module Files
    module Watchers
      class DirectoryWatcher < NodeWatcher
        def initialize( path )
          set_path( path )
          @watchers = create_watchers( self.path.entries )
        end
      
      
        # returns a hash of changes
        def update
          new_changeset do
            if self.path.exist?
              update_existing_files
              find_new_files
            else
              # If the directory is gone, you can assume the same is true
              # for all the files it held.  
              report_files( self.all_paths, :deleted )
            end
          end
        end
      
        def update_existing_files
          # first, check on the files we're supposed to be keeping track of
          for path, watcher in @watchers
            @changes[path] = :deleted unless path.exist?
            @changes.merge!( watcher.update )
          
            # While the main Watcher will continue to monitor the places it's
            # been told, even if they're missing, the subwatchers just disappear
            # when the files they're watching do.
            @watchers.delete( path ) unless path.exist?
          end
        end
      
        def find_new_files
          # next, get the updated list of files/folders beneath this directory
          current_paths = self.path.entries
        
          for path in current_paths
            unless @watchers.has_key?( path )
              w = Watcher.factory( path )
            
              report_files( w.all_paths, :created )

              @watchers[path] = w
            end
          end
        end
      
        # modify the current list of changes by adding "deleted" for 
        # every file/folder below this one.
        def report_files( paths, status )  
          for path in paths
            @changes[path] = status
          end 
        end
      
        def all_paths
          @watchers.map{|path, watcher| watcher.all_paths }.flatten + [self.path]
        end
      end
    end
  end
end
