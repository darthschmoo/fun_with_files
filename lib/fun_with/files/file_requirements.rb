module FunWith
  module Files
    module FileRequirements
      def needs_to_exist error_msg = "Path does not exist"
        _raise_error_if_not self.exist?, error_msg, Errno::ENOENT
      end
      
      def needs_to_be_a_file error_msg = "Path is not a file"
        self.needs_to_exist( error_msg + " (does not exist)" )
        _raise_error_if_not self.file?, error_msg, Errno::ENOENT
      end
      
      def needs_to_be_readable error_msg = "Path is not readable"
        self.needs_to_exist( error_msg + " (does not exist)" )
        _raise_error_if_not self.writable?, error_msg, Errno::EPERM
      end
      
      def needs_to_be_writable error_msg = "Path is not writable"
        self.needs_to_exist( error_msg + " (does not exist)" )
        _raise_error_if_not self.writable?, error_msg, Errno::EPERM
      end
      
      def needs_to_be_executable error_msg = "Path is not executable"
        self.needs_to_exist( error_msg + " (does not exist)" )
        _raise_error_if_not self.executable?, error_msg, Errno::ENOEXEC
      end
      
      # returns a different code depending on whether the path is a file
      # or a directory.
      def needs_to_be_empty error_msg = "Path needs to be empty"
        self.needs_to_exist( error_msg + " (does not exist)" )
        error_class = Errno::EOWNERDEAD                         # it's as good a code as any
        error_class = Errno::ENOTEMPTY       if self.directory?
        error_class = Errors::FileNotEmpty   if self.file?      # there's no libc error for "file oughta be empty"
        
        _raise_error_if_not self.empty?, error_msg, error_class
      end
      
      def needs_to_be_a_directory error_msg = "Path is not a directory"
        self.needs_to_exist( error_msg + " (does not exist)" )
        _raise_error_if_not self.directory?, error_msg, Errno::ENOTDIR
      end
      
      def needs_to_be( *requirements )
        for requirement in requirements
          case requirement
          when :exist
            self.needs_to_exist
          when :readable
            self.needs_to_be_readable
          when :writable
            self.needs_to_be_writable
          when :executable
            self.needs_to_be_executable
          when :empty
            self.needs_to_be_empty
          when :directory
            self.needs_to_be_a_directory
          when :file
            self.needs_to_be_a_file
          else
            warn "Did not understand file.needs_to_be constraint: #{arg}"
          end
        end
      end
      
      protected
      def _raise_error_if test, msg, error_class
        if test
          raise error_class.new( msg + "(file: #{self})" )
        end
      end
      
      def _raise_error_if_not test, msg, error_class
        _raise_error_if !test, msg, error_class
      end
    end
  end
end

