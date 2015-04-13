module FunWith
  module Files
    # Mostly just convenience methods for FileUtils
    module FileManipulationMethods
      # cd(dir, options)
      # cd(dir, options) {|dir| .... }
      # pwd()
      # mkdir(dir, options)
      # mkdir(list, options)
      # mkdir_p(dir, options)
      # mkdir_p(list, options)
      # ln(old, new, options)
      # ln(list, destdir, options)
      # ln_s(old, new, options)
      # ln_s(list, destdir, options)
      # ln_sf(src, dest, options)
      
      # opts are the last argument, and are passed to FileUtils.cp_r
      # returns the destination path.
      # How to detect failure?  What to return on failure?
      #
      # 
      def cp( *args )
        dest, opts = self.destination_and_options( args )
        FileUtils.cp_r( self, dest, narrow_options( opts, FileUtils::OPT_TABLE["cp_r"] ) )
        dest.fwf_filepath
      end
      
      alias :copy :cp
      
      def mv( *args )
        
      end
      
      
      # self is the target, link is the thing linking to self
      # returns filepath of the new link.  Will fall back to symbolic
      # link if self is a directory
      def ln( *args )
        self.destination_and_options( args ) do |link, opts|
          symlink = self.directory? || opts[:symbolic] || opts[:sym] || opts[:soft]
        
          if symlink
            FileUtils.ln_s( self, link, narrow_options( opts, FileUtils::OPT_TABLE["ln_s"] ) )
          else
            FileUtils.ln( self, link, narrow_options( opts, FileUtils::OPT_TABLE["ln"] ) )
          end
          
          link.fwf_filepath
        end
      end
      
      alias :link :ln

      
      def ln_s( *args )
        link, opts = self.destination_and_options( args )
        FileUtils.ln_s( self, link, narrow_options( opts, FileUtils::OPT_TABLE["ln_s"] ) )
        link.fwf_filepath
      end
      
      alias :symlink :ln_s
      
      
      def file_gsub( *args, &block )
        _must_be_a_file
        
        lines = []
        self.each_line do |line|
          lines << line.gsub( *args, &block )
        end
        
        lines.compact.join( "" )
      end
      
      def file_gsub!( *args, &block )
        _must_be_a_file      # raises error
        _must_be_writable    # raises error
        
        self.write( self.file_gsub( *args, &block ) )
      end
      
      def empty!
        if self.directory?
          FileUtils.rm_rf( self.entries, secure: true )
        else
          self.write( "" )
        end
      end
      
      # TODO: If it's truncated to a longer length than the original file,
      # pad with zeros?  That's how the UNIX truncate command works.
      def truncate( len )
        _must_be_a_file     # raises error
        _must_be_writable   # raises error
        
        old_size = self.size
        padding = len > old_size ? "\0" * (len - old_size) : ""
        
        self.write( self.read( len ) + padding )
      end
      
      # File manipulation
      def rename( filename )
        raise "NOT WORKING"
      end

      def rename_all( pattern, gsubbed )
        raise "NOT WORKING"
      end

      # pass options?
      def rm( secure = false )
        if self.file?
          FileUtils.rm( self )
        elsif self.directory?
          FileUtils.rmtree( self )
        end
      end
      
      protected
      def destination_and_options( args, &block )
        options = args.last.is_a?(Hash) ? args.pop : {}
        destination = self.find_destination_from_args( args )
        
        if block_given?
          yield [destination, options]
        else
          [destination, options]
        end
      end
      
      
      # logic should be shared by various manipulators
      # 
      # You can describe the destination as either a filepath or a bunch of strings for arguments.
      # If the FilePath is relative, or if string args are given, then the destination will be
      # relative to the path being copied (or in the case of a file, its parent directory).
      #
      # If dest doesn't exist, and src (self) is a file, dest is taken to be the complete path.
      # If dest doesn't exist, and src (self) is a directory, then dest is taken to be 
      # If dest is a directory and the source is a file, then the file will be copied into dest with the src's basename
      def find_destination_from_args( args )
        raise ArgumentError.new("File #{self} must exist.") unless self.exist?
        
        if args.first.is_a?(Pathname) 
          raise ArgumentError.new( "accepts a FilePath or string args, not both" ) unless args.length == 1
          dest = args.first
          dest = dest.directory.join( dest ).expand if dest.relative?
        else
          dest = self.directory.join(*args).expand  # expand gets rid of /../ (parent_dir)
        end
        
        if self.file? && dest.directory?
          dest = dest.join( self.basename )
        elsif self.directory? && dest.file?
          raise ArgumentError.new( "cannot overwrite a file with a directory" )
        end
                
        dest
      end
        
      # rm(list, options)
      # rm_r(list, options)
      # rm_rf(list, options)
      # rmdir(dir, options)
      # rmdir(list, options)

      
      # def cp( dest, options = {} )
      #   raise NoSuchFile.new( "No such file as #{self} to copy" ) unless self.exist?
      #   
      #   dest = dest.fwf_filepath.expand
      #   
      #   if self.directory?
      #     # touch dest directory?
      #     FileUtils.cp_r( self, dest, options)
      #   else
      #     dest = dest.join( self.basename ) if dest.directory?
      #     dest_dir = dest.up.touch_dir
      #     
      #     raise NotWritable.new( "Could not create directory or directory not writable: #{dest_dir}" ) unless dest_dir.directory? && dest_dir.writable?
      #     
      #     FileUtils.cp( self, dest, options ) unless dest.exist? && options[:safe]
      #   end
      #   
      #   dest
      # end
      # 
      # 
      
      # cp_r(src, dest, options)
      # cp_r(list, dir, options)
      
      
      
      # mv(src, dest, options)
      # mv(list, dir, options)
      # install(src, dest, mode = <src's>, options)
      # chmod(mode, list, options)
      # chmod_R(mode, list, options)
      # chown(user, group, list, options)
      # chown_R(user, group, list, options)
      # touch(list, options)
      
    end
  end
end