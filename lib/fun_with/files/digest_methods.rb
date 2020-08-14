module FunWith
  module Files
    DIGEST_METHODS = [:md5, :sha1, :sha2, :sha224, :sha256, :sha384, :sha512]
    
    module DigestMethods
      def md5( bytes = :all, offset = 0 )
        digest( Digest::MD5, bytes, offset )
      end
      
      def sha1( bytes = :all, offset = 0 )
        digest( Digest::SHA1, bytes, offset )
      end
      
      def sha2( bytes = :all, offset = 0 )
        digest( Digest::SHA2, bytes, offset )
      end

      def sha224( bytes = :all, offset = 0 )
        digest( Digest::SHA224, bytes, offset )
      end

      def sha256( bytes = :all, offset = 0 )
        digest( Digest::SHA256, bytes, offset )
      end

      def sha384( bytes = :all, offset = 0 )
        digest( Digest::SHA384, bytes, offset )
      end
      
      def sha512( bytes = :all, offset = 0 )
        digest( Digest::SHA512, bytes, offset )
      end
      
      def digest( digest_class = Digest::MD5, bytes = :all, offset = 0  )
        if self.file? && self.readable?
          if bytes == :all
            digest_class.hexdigest( self.read )
          elsif bytes.is_a?( Integer )
            digest_class.hexdigest( self.read( bytes, offset ) )
          else
            raise ArgumentError.new( "FunWith::Files::DigestMethods.digest() error: bytes argument must be an integer or :all")
          end
        else
          raise IOError.new( "Not a file: #{self.path}" ) unless self.file?
          raise IOError.new( "Not readable: #{self.path}" ) unless self.readable?
        end
      end
      
      # Takes any of the above-named digest functions, determines
      # whether the file matches a given digest string.
      # 
      # Multiple digests can be given simultaneously.  All must pass.
      #
      # TODO: how to get around the :md6 problem?  That is, where the
      # user is sending the wrong key, and hence not getting false back
      def valid_digest?( opts )
        for method, digest in opts
          if DIGEST_METHODS.include?( method )
            return false unless self.send( method ) == digest
          end
        end
        
        return true
      end 
    end
  end
end