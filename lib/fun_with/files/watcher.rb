# You want to watch a list of files or directories for changes 
# (files created, deleted, or modified), and then return a... list?
# of changes.  
#
# Tricky part is, what constitutes a "change" for a directory.
# or a file, for that matter.
#
# Cool expansion: customize the sorts of changes that trigger actions.
# You can already do that to some extent with the user-code that the
# change list is delivered to
#
# usr/ (modified, watched)
#   bin/ (modified)
#     new_directory/ (created)
#       README.txt (created)
#     bash (unchanged)
#     
#   lib/ (modified)
#     libgpg.so (unchanged)
#     libmysql.so (deleted)
#     libzip.so (modified)
#     libjpeg.so  (file_created)
#     you_have_been_hacked_by_chinese.txt (file_created)
#  cache/ (deleted)
#    firefox/ (deleted)
#      cached_item.jpg (deleted)
#      cached_folder/ (deleted)
#        cache_file.csv (deleted)
#
# When you find a change in a subdirector/file, the :modified status 
# propagates up the tree.
# Feels like a job for a visitor.
#
# If you create the top-level watcher, it could create any sub-watchers 
# for the files and folders.  It asks its watchers to update their 
# statuses and report back.
#
# But the top-level one should know that it's the top level, so it
# shouldn't be deleting its watchers that might be, for example, 
# waiting for a file to come into being. 
#
# Hence, anyone using this code probably ought to stick to using the main Watcher
# class, and not worry about the ones it uses in the background
#
# Filters can be added
module FunWith
  module Files
    class Watcher
      def self.watch( *paths, interval: 1.0, notice: [], ignore: [], &block )
        watcher = self.new( paths ).sleep_interval( interval ).filter( notice: notice, ignore: ignore )
        
        if block_given?
          watcher.watch( &block )
        else
          watcher
        end
      end
      
      def self.factory( path )
        path = path.fwf_filepath
        
        if path.exist?
          if path.directory?
            Watchers::DirectoryWatcher.new( path )
          elsif path.file?
            Watchers::FileWatcher.new( path )
          end
        else
          Watchers::MissingWatcher.new( path )
        end
      end
      
      def initialize( paths )
        @sleep_interval = 1.0
        @notice_filters = []
        @ignore_filters = []
        
        # Create a watcher for every single thing that we're
        # asking it to watch
        @watchers = paths.inject({}) do |watchers, path|
          watchers[path.fwf_filepath] = self.class.factory( path )
          watchers
        end
      end
      
      def sleep_interval( i )
        @sleep_interval = i
        self
      end
      
      def watch( &block )
        while true
          sleep( @sleep_interval )
          yield self.update
        end
      end
      
      def filter( notice: [], ignore: [] )
        @notice_filters += [notice].flatten
        @ignore_filters += [ignore].flatten
        
        self
      end
      
      # returns a hash of the changes that have happened in the file system being monitored,
      def update
        {}.tap do |changes|
          for path, watcher in @watchers
            changes.merge!( watcher.update )
            replace_watcher( path, changes[path] )  # a DirectoryWatcher might need to be replaced with a MissingWatcher, for example, or vice-versa
            
            # corner case: if a directory is created, everything created under the directory
            # is deemed to have also been created at the same time
            if path.directory? && changes[path] == :created
              changes.merge!( path.glob(:all).inject({}){ |memo,path| memo[path] = :created ; memo } )
            end
          end
          
          apply_filters( changes )
        end
      end
      
      def replace_watcher( path, change )
        case change
        when nil
          # didn't change
        when :deleted, :created
          @watchers[path] = self.class.factory( path )
        end
      end
      
      # 
      def apply_filters( changes )
        apply_notice_filters( changes )
        apply_ignore_filters( changes )
        changes
      end
      
      def apply_notice_filters( changes )
        for filter in @notice_filters
          for path in changes.keys
            changes.delete( path ) if path !~ filter
          end
        end
      end
      
      def apply_ignore_filters( changes )
        for filter in @ignore_filters
          for path in changes.keys
            changes.delete( path ) if path =~ filter
          end
        end
      end
    end
  end
end

