   
module FunWith
  module Files
    module Watchers
      class FileWatcher < NodeWatcher
        attr_accessor :last_modified
      
        def initialize( path )
          set_path( path )
          refresh_last_modified
        end
      
        def refresh_last_modified
          self.last_modified = self.path.stat.mtime if self.path.exist?
        end
      
        def modified?
          self.path.exist? && self.last_modified < self.path.stat.mtime
        end
      
        def deleted?
          ! self.path.exist?
        end
      
        def update
          if deleted?
            { self.path => :deleted }
          elsif modified?
            refresh_last_modified
            { self.path => :modified }
          else
            {}
          end
        end
        
        # returns all paths below it in the hierarchy, including 
        # the path of the node itself.  In this case, there's
        # only one path to return.
        def all_paths
          [self.path]
        end
      end
    end
  end
end