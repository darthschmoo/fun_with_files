module FunWith
  module Files
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
    end
  end
end