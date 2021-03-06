module FunWith
  module Files
    # FileOrderer holds a set of strings/regexes, then reorders a set of files (FunWith::Files::FilePaths, actually)
    # by matching the filenames against one regex after another.  Allows you to say,
    # "I want the title page, the foreward, then all the chapters, then all the appendixes, then the afterword."
    # Ex:  FileOrderer( ["title_page", "forward", "chapter-.*", "afterword", "appendix.*" ).reorder( pages )
    # Only compares the basename minus extension.  Files should come from the same directory.  cover.extension always comes first.
    class FileOrderer
      def initialize( matchers )
        @matchers = matchers.map do |m| 
          case m
          when Regexp
            m
          when String
            /^#{m}$/
          end
        end
        
        @matchers.unshift( /^cover$/ )
        @matchers.push( /^.*$/ )
      end
      
      def reorder( files )
        files = files.map(&:fwf_filepath)
        
        ordered_files = @matchers.inject( [] ) do |collector, matcher|
          matched_files = files.select do |f| 
            name = f.basename_no_ext.to_s
            matcher.match( name )
          end
          
          matched_files.sort_by! do |filename|
            filename.basename_no_ext.to_s
          end
          
          collector += matched_files.sort
          files -= matched_files
          
          collector
        end
        
        ordered_files
      end
    end
  end
end