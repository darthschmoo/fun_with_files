module FunWith
  module Files
    module CoreExtensions
      module Hash
        def fwf_blank?
          self.length == 0
        end
  
        # Stolen from: activesupport/lib/active_support/core_ext/hash/reverse_merge.rb, line 12
        def fwf_reverse_merge( other_hash )
          other_hash.merge( self )
        end
  
        # File activesupport/lib/active_support/core_ext/hash/reverse_merge.rb, line 17
        def fwf_reverse_merge!(other_hash)
          # right wins if there is no left
          merge!( other_hash ){|key,left,right| left }
        end
      end
    end
  end
end

