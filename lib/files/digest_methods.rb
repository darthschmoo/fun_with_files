module FunWith
  module Files
    module DigestMethods
      def md5
        self.file? ? Digest::MD5.hexdigest( self.read ) : ""
      end
    end
  end
end