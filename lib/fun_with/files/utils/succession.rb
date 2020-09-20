module FunWith
  module Files
    module Utils
      class Succession
        def self.get_successor_name( basename, digit_count )
          pieces = basename.to_s.split(".")
          
          if pieces.length == 0
            pieces = [ self.format_counter( 0, digit_count ) ]
          elsif is_counter?( pieces.last, digit_count )
            pieces = self.increment_position( pieces, pieces.length - 1 )
          elsif is_counter?( pieces[-2], digit_count )
            pieces = self.increment_position( pieces, pieces.length - 2 )
          else
            pieces = self.install_counter( pieces, digit_count )
          end
          
          pieces.join(".")
        end
        
        def self.is_counter?( str, digit_count )
          return false if str.nil?
          (str =~ /^\d{#{digit_count}}$/) != nil
        end
        
        def self.format_counter( i, len )
          sprintf( "%0#{len}i", i )
        end
        
        def self.increment_position( arr, pos_to_increment )
          arr.map.each_with_index do |str, i|
            if i == pos_to_increment
              self.format_counter( str.to_i + 1, str.length )
            else
              str
            end
          end
        end
        
        def self.install_counter( arr, count )
          counter = self.format_counter( 0, count )
          arr[0..-2] + [counter] + [arr[-1]]
        end
      end
    end
  end
end