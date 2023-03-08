module FunWith
  module Files
    module Utils
      class TimestampFormat
        # the timestamp identifies a chunk of the filename
        # to be its kind of timestamp by checking it against a 
        # regular expression.  
        def recognizer( regex )
          @recognizer = regex
          self
        end
        
        # The strftime format used to output the timestamp
        def strftime( s )
          @strftime_format = s
          self
        end
        
        def format_time( t )
          t.strftime( @strftime_format )
        end
        
        # does the given chunk look like a timestamp using this format?
        # returns true or false.  
        def matches?( str, &block )
          @recognizer.match( str ) != nil
        end
      end
    end
  end
end