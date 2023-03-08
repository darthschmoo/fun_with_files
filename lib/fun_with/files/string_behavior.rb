# Allow FilePaths to participate in some of the String-based mischief.

module FunWith
  module Files
    module StringBehavior
      def =~( rhs )
        @path =~ rhs
      end
      
      def !~( rhs )
        @path !~ rhs
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
      
      def scan( *args, &block )
        @path.scan( *args, &block )
      end
      
      # Lets it be a string when a string is called for.  Replacement argument in .gsub(), for example.
      def to_str
        @path.dup
      end
    end
  end
end