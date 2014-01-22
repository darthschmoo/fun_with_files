# Allow FilePaths to participate in some of the String-based mischief.

module FunWith
  module Files
    module StringBehavior
      def =~( rval )
        @path =~ rval
      end
      
      def match( *args )
        @path.match( *args )
      end
      
      # gsub acts on the filepath, not the file contents
      def gsub( *args )
        @path.gsub(*args).fwf_filepath
      end
      
      def gsub!( *args )
        @path = @path.gsub(*args)
      end
    end
  end
end