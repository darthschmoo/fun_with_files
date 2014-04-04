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
      
      def cp( *args )
        self.destination_and_options( args ) do |dest, opts|
          FileUtils.cp_r( self, dest, opts )
          dest.fwf_filepath
        end
      end
      
      alias :copy :cp
      
      # self is the target, link is the thing linking to self
      # returns filepath of the new link.  Will fall back to symbolic
      # link if self is a directory
      def ln( *args )
        self.destination_and_options( args ) do |link, opts|
          symlink = self.directory? || opts[:symbolic] || opts[:sym] || opts[:soft]
        
          if symlink
            FileUtils.ln_s( self, link, opts )
          else
            FileUtils.ln( self, link, opts )
          end
        
          link.fwf_filepath
        end
      end
      
      def ln_s( link, options = {} )
        FileUtils.ln_s( self, link, options )
        link.fwf_filepath
      end
      
      def file_gsub( *args, &block )
        lines = []
        self.each_line do |line|
          lines << line.gsub( *args, &block )
        end
        
        lines.compact.join( "" )
      end
      
      def file_gsub!( *args, &block )
        self.write( self.file_gsub(*args,&block) )
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
      def find_destination_from_args( args )
        if args.first.is_a?(Pathname) 
          dest = args.first
        elsif self.directory?
          # what if they're trying to define an absolute dest, but being splitty?
          dest = self.join( *args )
        else
          # ......
          dest = self.dirname.join( *args )
          dest = dest.join( self.basename ) if dest.directory?
        end
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