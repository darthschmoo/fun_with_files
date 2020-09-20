module FunWith
  module Files
    module Utils
      class Timestamp
        # Currently exactly one format is supported.  Laaaaame!
        
        def self.format( key )
          @formats ||= {
            :default => TimestampFormat.new.recognizer( /^\d{17}$/ ).strftime("%Y%m%d%H%M%S%L"),
            :ymd     => TimestampFormat.new.recognizer( /^\d{4}-\d{2}-\d{2}$/ ).strftime("%Y-%m-%d"),
            :ym      => TimestampFormat.new.recognizer( /^\d{4}-\d{2}$/ ).strftime("%Y-%m"),
            :y       => TimestampFormat.new.recognizer( /^\d{4}$/ ).strftime("%Y"),
            
            # UNIX timestamp
            :s       => TimestampFormat.new.recognizer( /^\d{10}$/ ).strftime("%s")
          }
          
          if @formats.has_key?(key)
            @formats[key]
          else
            raise TimestampFormatUnrecognized.new( "Unrecognized timestamp format (#{key.inspect}).  Choose from #{@formats.keys.inspect}" )
          end
        end
        
        def self.timestamp( basename, format: :default, splitter: ".", time: Time.now )
          filename_chunks = basename.to_s.split( splitter )
          format = format.is_a?( TimestampFormat ) ? format : self.format( format )
          new_timestamp = format.format_time( time )
          
          timestamp_index = filename_chunks.map.each_with_index{ |str,i| 
            format.matches?( str ) ? i : nil
          }.compact.last
          
          if timestamp_index
            filename_chunks[timestamp_index] = new_timestamp
          elsif filename_chunks.length == 1
            filename_chunks << new_timestamp
          else
            filename_chunks.insert( -2, new_timestamp )
          end
          
          filename_chunks.join( splitter )
        end
      end
    end
  end
end
