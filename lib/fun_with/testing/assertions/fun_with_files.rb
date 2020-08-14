module FunWith
  module Testing
    module Assertions
      module FunWithFiles
        # The object given must be an instance of class FilePath
        def assert_fwf_filepath( file, msg = nil )
          msg = message(msg){ "File <#{file}> should be a FunWith::Files::FilePath" }
          assert_kind_of FunWith::Files::FilePath, file, msg  
        end
        
        # The object given is an instance of class FilePath, and points to
        # a file that exists.
        def assert_file( file, msg = nil )
          assert_fwf_filepath( file, message(nil){ "...is not a file." } )
          
          msg = message(msg){ "File should exist at <#{file}>." }
          assert file.file?, msg
        end
        
        # The object given is a filepath, but doesn't point to 
        # an existing file or directory.  
        def assert_no_file( file, msg = nil )
          assert_fwf_filepath( file, message )
          msg = message(msg){ "No file/directory should exist at <#{file}>." }
          refute file.file?, msg
        end
        
        # The object given is a filepath, and points to a directory
        def assert_directory( file, msg = nil )
          assert_fwf_filepath( file, msg )
          msg = message(msg){ "<#{file}> should be a directory." }
          assert file.directory?, msg
        end
        
        # The object given is a filepath, but doesn't point to a directory.
        def assert_not_directory( file, msg = nil )
          assert_fwf_filepath( file, message )
          msg = message(msg){ "<#{file}> shouldn't be a directory." }
          refute file.directory?
        end
        
        # The object given is a filepath.
        # It points to a file that exists.
        # That file is empty.
        def assert_empty_file( file, msg = nil )
          assert_fwf_filepath( file )
          msg = message(msg){ "Empty file should exist at <#{file}>." }
          assert file.file? && file.empty?, msg
        end
        
        # The object given is a filepath.
        # It points to a directory that exists.
        # That directory is empty.
        def assert_empty_directory( file, msg = nil )
          assert_fwf_filepath( file )
          msg = message(msg){ "Empty directory should exist at <#{file}>." }
          assert file.directory? && file.empty?
        end
        
        
        # The object given is a filepath.
        # It points to a file that exists.
        # That file contains content.
        def assert_file_has_content( file, msg = nil )
          assert_fwf_filepath( file, message )
          msg = message(msg){ "File should exist at <#{file}>, and have content." }
          assert file.exist?, msg.call + "(file does not exist)"
          assert file.file?, msg.call + "(not a file)"
          refute file.empty?, msg.call + "(file is not empty)"
        end
        
        alias :assert_file_not_empty :assert_file_has_content
        
        
        def assert_file_contents( file, content, msg = nil )
          assert_file( file )
          
          case content
          when String
            # message = build_message( message, "File <#{file}> contents should be #{content[0..99].inspect}#{'...(truncated)' if content.length > 100}" )
            assert_equal( content, file.read, msg )
          when Regexp
            assert_match( content, file.read, msg )
          end
        end
        
        
      end
    end
  end
end