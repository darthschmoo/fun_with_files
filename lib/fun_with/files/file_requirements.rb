module FunWith
  module Files
    module FileRequirements
      def _raise_error_if_not test, msg, error_class
        if test
          raise error_class.new( msg + "(file: #{self})" )
        end
      end
      
      def needs_to_be_a_file error_msg = "Path is not a file"
        _raise_error_if_not self.file?, error_msg, Errno::ENOENT
      end
      
      def needs_to_be_writable error_msg = "Path is not writable"
        _raise_error_if_not self.writable?, error_msg, Errno::ENOENT
      end
      
      def needs_to_be_empty error_msg = "Path needs to point to"
        _raise_error_if_not self.empty?, error_msg, Errno::ENOENT
      end
      
      def needs_to_be_a_directory error_msg = "Path is not a directory"
        _raise_error_if_not self.directory?, error_msg, Errno::ENOENT
      end
    end
  end
end

