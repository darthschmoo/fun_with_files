module FunWith
  module Files
    module Utils
      module ByteSize
        "ideas"
        "format:   %u - units (lowercase), %k - units (uppercase), %b - units (lower, with b), %B"
        "          %3 - humanized value, three sigfigs, meaning that if it's under 10, you get '7.32'"
        "               but if it's over 100, rounds to the nearest full number.  10-99, it goes"
        "               down to the tenths prare"
        "or just give an example: 7.32 kb"
        
        # format:   "your filesize is (%n.nn %u)"
        
        
        UNITS = {
          :B => 1,
          :KB => 1_000,
          :MB => 1_000_000,
          :GB => 1_000_000_000,
          :TB => 1_000_000_000_000,
          :PB => 1_000_000_000_000_000,
          :EB => 1_000_000_000_000_000_000,
          :ZB => 1_000_000_000_000_000_000_000
        }
        
        UNIT_STANDARDIZERS = { "" => :B, "B" => :B, "b" => :B }
        
        for s in %w(K M G T P E Z KB MB GB TB PB EB ZB)
          unit_sym = s.length == 1 ? :"#{s}B" : :"#{s}"
          UNIT_STANDARDIZERS[s]          = unit_sym
          UNIT_STANDARDIZERS[s.downcase] = unit_sym
          UNIT_STANDARDIZERS[s.to_sym]   = unit_sym
        end
        
        def convert( expr, units = :B )
          to_units( to_bytes( expr ), units )
        end
        
        # Takes a string of the form "<NUMBER><UNIT>"
        # and returns the number of bytes represented.
        # See UNITS constant for valid constants
        def to_bytes( expr )
          regexp = /^\s*(?<num>\d+(\.\d+)?)\s*(?<unit>(k|m|g|t|p|z|)b?)\s*$/i
          
          if m = expr.upcase.match( regexp )
            num   = m[:num].to_f
            units = standardize_unit( m[:unit] )
            # units = case units.length
            #         when 0
            #           :B
            #         when 1
            #           (units == "B" ? units : units + "B").to_sym
            #         when 2
            #           units.to_sym
            #         end
            debugger unless UNITS.has_key?(units)
            (num * UNITS[units]).to_i
          else
            raise ArgumentError.new( "#{expr} is not in a format that to_bytes recognizes")
          end
        end
        
        # Looking for a human-friendly vibe more than accuracy.
        # At most one unit of post-decimal precision, and only
        # for small numbers.  If the tenths place is a zero,
        # the trailing zero is dropped.
        def to_units( byte_count, unit )
          num = byte_count.to_f / UNITS[standardize_unit(unit)]
          # the first comparison gets rid of leading zeros
          # the second comparison prevents the decimal from being printed 
          # when it doesn't make a big difference
          if num == num.to_i || num >= 100        # 9.9k 10k
            num_str = num.to_i.to_s
          else
            num_str = sprintf( "%0.01f", num )
          end
          
          num_str = num_str[0..-3] if num_str[-2..-1] == ".0"
          
          num_str + unit.to_s
        end
          
        def standardize_unit( unit )
          # So the caller can add a space if desired, but ultimately it might be
          # better to offer more flexible formatting options.
          unit = unit.strip if unit.respond_to?(:strip)   
          
          if UNIT_STANDARDIZERS.has_key?( unit )
            UNIT_STANDARDIZERS[unit]
          else
            raise ArgumentError.new( "ByteSize.to_units doesn't understand the unit #{unit.inspect}(unit.class)" )
          end
        end
        
        
        def humanize_bytes( bytes )
          return "?" unless bytes.is_a?( Integer ) && bytes >= 0
    
          bytes = bytes.to_f
    
          if bytes > 1_000_000_000
            exp = "G"
            amt = bytes / 1_000_000_000
          elsif bytes > 1_000_000
            exp = "M"
            amt = bytes / 1_000_000
          elsif bytes > 1_000
            exp = "K"
            amt = bytes / 1_000
          else
            exp = "B"
            amt = bytes
          end
    
          if amt > 10
            digits = 0
          elsif amt > 1
            digits = 1
          end
    
          sprintf( "%0.#{digits}f", amt ) + exp
        end
        
        # returns a string of numbers, representing the float 
        # d - number of figures after the zero (max)
        def limited_precision_value( f, d )
          # 4, 1234.5 -> 1234
          # 4, 123.45 -> 123.4
          # 4, 12.3423 -> 12.34
          # 4, 0.0001  -> 0.0001 ->  - 1234.5, 123.45, 12.345, 1.2345 0.1234 0.0123
          # 2 - 1234, 123, 12.3, 1.23, 0.12, 0.01
          # 1 - 12.3, 12, 1
          # 0 - 12, 1, 0
          #
          #
          #
          #
          #
        end
      end
    end
  end
end