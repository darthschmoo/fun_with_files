module FunWith
  module Files
    DIGEST_METHODS = [:md5, :sha1, :sha2, :sha224, :sha256, :sha384, :sha512]
    
    module DigestMethods
      def md5
        digest( Digest::MD5 )
      end
      
      def sha1
        digest( Digest::SHA1 )
      end
      
      def sha2
        digest( Digest::SHA2 )
      end

      def sha224
        digest( Digest::SHA224 )
      end

      def sha256
        digest( Digest::SHA256 )
      end

      def sha384
        digest( Digest::SHA384 )
      end
      
      def sha512
        digest( Digest::SHA512 )
      end
      
      def digest( digest_class = Digest::MD5 )
        self.file? ? digest_class.hexdigest( self.read ) : ""
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