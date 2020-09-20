module FunWith
  module Files
    class FilePath < Pathname
      SUCC_DIGIT_COUNT = 6

      def initialize( *args, &block )
        super( File.join( *(args.map(&:to_s) ) ) )
        _yield_and_return( self, &block )
      end

      attr_accessor :path
      
      # If block given, temporary directory is deleted at the end of the block, and the
      # value given by the block is returned.
      # 
      # If no block given, the path to the temp directory is returned as a FilePath.
      # Don't forget to delete it when you're done.
      def self.tmpdir( &block )
        if block_given?
          Dir.mktmpdir do |d|
            yield d.fwf_filepath
          end
        else
          Dir.mktmpdir.fwf_filepath
        end
      end
      
      # The file is created within a temporary directory
      def self.tmpfile( ext = :tmp, &block )
        filename = rand( 2 ** 64 ).to_s(16).fwf_filepath.ext( ext )
        
        if block_given?
          self.tmpdir do |tmp|
            yield tmp.join( filename ).touch
          end
        else
          self.tmpdir.join( filename ).touch
        end
      end

      def join( *args, &block )
        joined_path = self.class.new( super( *(args.map(&:to_s) ) ) )
        _yield_and_return( joined_path, &block )
      end
      
      def join!( *args, &block )
        @path = self.join( *args, &block ).to_str
        _yield_and_return( self, &block )
      end
      
      def /( arg, &block )
        _yield_and_return( self.join( arg ), &block )
      end
      
      def []( *args, &block )
        _yield_and_return( self.join(*args), &block )
      end
      
      
      def doesnt_exist?
        self.exist? == false
      end
      
      def not_a_file?
        ! self.file?
      end

      alias :absent? :doesnt_exist?
      alias :exists? :exist?
      alias :folder? :directory?

      # If called on a file instead of a directory,
      # has the same effect as path.dirname
      def up
        self.class.new( self.join("..") ).expand
      end

      alias :down :join

      # opts:
      #    :flags  =>  File::FNM_CASEFOLD
      #                File::FNM_DOTMATCH
      #                File::FNM_NOESCAPE
      #                File::FNM_PATHNAME
      #                File::FNM_SYSCASE
      #                See Dir documentation for details.
      #                  Can be given as an integer: (File::FNM_DOTMATCH | File::FNM_NOESCAPE)
      #                  or as an array: [File::FNM_CASEFOLD, File::FNM_DOTMATCH]
      #
      #    :class  =>  [self.class] The class of objects you want returned (String, FilePath, etc.)
      #                Should probably be a subclass of FilePath or String.  Class.initialize() must accept a string
      #                [representing a file path] as the sole argument.
      #
      #    :recurse => [defaults true]
      #    :recursive (synonym for :recurse)
      #
      #    :ext => []  A single symbol, or a list containing strings/symbols representing file name extensions.
      #                No leading periods kthxbai.
      #    :sensitive => true : do a case sensitive search.  I guess the default is an insensitive search, so
      #                         the default behaves similarly on Windows and Unix.  Not gonna fight it.
      #
      #    :dots => true      : include dotfiles.  Does not include . and ..s unless you also
      #                         specify the option :parent_and_current => true.
      #
      #    If opts[:recurse] / opts[:ext] not given, the user can get the same
      #    results explicitly with arguments like .glob("**", "*.rb")
      #
      # :all : if :all is the only argument, this is the same as .glob("**", "*")
      #
      # Examples:
      # @path.glob( "css", "*.css" )      # Picks up all css files in the css folder
      # @path.glob( "css", :ext => :css ) # same
      # @path.glob                        # Picks up all directories, subdirectories, and files
      # @path.glob(:all)                  # same. Note: :all cannot be used in conjunction with :ext or any other arguments.  Which may be a mistake on my part.
      # @path.glob("**", "*")             # same
      # @path.entries                     # synonym for :all, :recursive => false
      #
      # TODO:  depth argument?  depth should override recurse.  When extention given, recursion should default to true?
      #        the find -depth argument says depth(0) is the root of the searched directory, any files beneath would be depth(1)
      def glob( *args, &block )
        args.push( :all ) if args.fwf_blank?
        opts = args.last.is_a?(Hash) ? args.pop : {}

        if args.last == :all
          all_arg_given = true
          args.pop
        else
          all_arg_given = false
        end

        flags = case (flags_given = opts.delete(:flags))
                when NilClass
                  0
                when Array      # should be an array of integers or File::FNM_<FLAGNAME>s
                  flags_given.inject(0) do |memo, obj|
                    memo | obj
                  end
                when Integer
                  flags_given
                end

        flags |= File::FNM_DOTMATCH if opts[:dots]
        flags |= File::FNM_CASEFOLD if opts[:sensitive]   # case sensitive.  Only applies to Windows.

        recurse = if all_arg_given
                    if opts[:recursive] == false || opts[:recurse] == false
                      false
                    else
                      true
                    end
                  else
                    opts[:recursive] == true || opts[:recurse] == true || false
                  end

        if all_arg_given
          if recurse
            args = ["**", "*"]
          else
            args = ["*"]
          end
        else
          args.push("**") if recurse

          extensions = case opts[:ext]
          when Symbol, String
            "*.#{opts[:ext]}"
          when Array
            extensions = opts[:ext].map(&:to_s).join(',')
            "*.{#{extensions}}"                            # The Dir.glob format for this is '.{ext1,ext2,ext3}'
          when NilClass
            if args.fwf_blank?
              "*"
            else
              nil
            end
          end

          args.push( extensions ) if extensions
        end

        class_to_return = opts[:class] || self.class

        files = Dir.glob( self.join(*args), flags ).map{ |f| class_to_return.new( f ) }
        files.reject!{ |f| f.basename.to_s.match( /^\.\.?$/ ) } unless opts[:parent_and_current]

        if block_given?
          for file in files
            yield file
          end
        else
          files
        end
      end

      def entries( &block )
        rval = self.glob( :recurse => false )
        
        if block_given?
          for entry in rval
            yield entry
          end
        end
        
        rval
      end

      def expand
        self.class.new( File.expand_path( self ) )
      end

      # Raises error if self is a file and args present.
      # Raises error if the file is not accessible for writing, or cannot be created.
      # attempts to create a directory
      #
      # Takes an options hash as the last argument, allowing same options as FileUtils.touch
      def touch( *args, &block )
        args, opts = Utils::Opts.extract_opts_from_args( args )

        raise "Cannot create subdirectory to a file" if self.file? && args.length > 0
        touched = self.join(*args)

        dir_for_touched_file = case args.length
          when 0
            self.up
          when 1
            self
          when 2..Float::INFINITY
            self.join( *(args[0..-2] ) )
          end

        self.touch_dir( dir_for_touched_file, opts ) unless dir_for_touched_file.directory?
        FileUtils.touch( touched, ** Utils::Opts.narrow_file_utils_options( opts, :touch ) )

        yield touched if block_given?
        return touched
      end

      # Takes the options of both FileUtils.touch and FileUtils.mkdir_p
      # mkdir_p options will only matter if the directory is being created.
      def touch_dir( *args, &block )
        args, opts = Utils::Opts.extract_opts_from_args( args )

        touched = self.join(*args)
        if touched.directory?
          FileUtils.touch( touched, ** Utils::Opts.narrow_file_utils_options( opts, :touch ) )    # update access time
        else
          FileUtils.mkdir_p( touched, ** Utils::Opts.narrow_file_utils_options( opts, :mkdir_p ) )  # create directory (and any needed parents)
        end

        yield touched if block_given?
        return touched
      end

      def write( *args, &block )
        args, opts = Utils::Opts.extract_opts_from_args( args )

        content = args.first

        if content == :random
          self.write_random_data( opts )
        else
          File.open( self, "w" ) do |f|
            f << content if content
            if block_given?
              yield f
            end
          end
        end
      end

      # sz:  number of bytes to write to the file
      # opts[:mode] => :overwrite or :append
      # seed:  What number to seed the random number generator with
      #
      # FUTURE:  May perform slowly on large sz inputs?
      def write_random_data( sz, opts = {} )
        rng = Random.new( opts[:seed] || Random::new_seed )
        mode = opts[:mode] || :overwrite

        if mode == :overwrite
          self.write( rng.bytes( sz ) )
        elsif mode == :append
          self.append( rng.bytes( sz ) )
        end
      end

      def append( content = nil, &block )
        File.open( self, "a" ) do |f|
          f << content if content
          if block_given?
            yield f
          end
        end
      end
      
      alias :<< :append

      # Returns a [list] of the lines in the file matching the given file.  Contrast with

      def grep( regex, &block )
        return [] unless self.file?
        matching = []
        self.each_line do |line|
          matching.push( line ) if line.match( regex )
          yield line if block_given?
        end


        matching
      end

      # empty? has different meanings depending on whether you're talking about a file
      # or a directory.  A directory must not have any files or subdirectories.  A file
      # must not have any data in it.
      def empty?
        raise Exceptions::FileDoesNotExist unless self.exist?

        if self.file?
          File.size( self ) == 0
        elsif self.directory?
          self.glob( :all ).fwf_blank?
        end
      end

      # Does not return a filepath
      #
      # TODO: Why not?
      def basename_no_ext
        self.basename.to_s.split(".")[0..-2].join(".")
      end
      
      # 
      def size( units = :B )
        sz = self.stat.size
        
        case units
        when :B
          sz
        when :K
          (sz / 1024.0).round(1)
        when :M
          (sz / 1048576.0).round(1)
        when :G
          (sz / 1073741824.0).round(1)
        end
      end

      # Returns the path, stripped of the final extension (.ARG).
      # The result cannot destroy a dotfile or leave an empty
      # path
      #   "~/.bashrc".without_ext( .bashrc )  => "~/.bashrc",
      # if an argument is given, the final ext must match
      # the given argument, or a copy of the unaltered path
      # is returned.
      #
      # Also:
      #    Don't add a leading ./ when the original didn't have one
      #    Case InSeNSItive, because I can't think of a use case for "only"
      #       strip the extension if the capitalization matches
      #    Chews up any number of leading '.'s
      #    For the moment, 
      def without_ext( ext_val = nil )
        ext_chopper_regex = if ext_val.fwf_blank?
                              /\.+\w+$/i             # any ending "word characters"
                            else
                              # It's okay for the caller to make the leading period explicit
                              ext_val = ext_val.to_s.gsub( /^\./, '' )
                              /\.+#{ext_val}+$/i
                            end

        chopped_str = @path.gsub( ext_chopper_regex, "" )
        
        do_we_chop = if chopped_str == @path   # no change, then sure, why not?
                       true
                     elsif chopped_str.fwf_blank? || chopped_str[-1] == self.separator() || chopped_str[-1] == "."
                       false
                     else
                       true
                     end
                     
        self.class.new( do_we_chop ? chopped_str : @path )
        
        # # If the results fail to live up to some pre-defined
        #
        #
        #
        # # do we or don't we?
        # chop_extension = true
        #
        # #   Don't if there's an extension mismatch
        # #   Don't if the remainder is a /. (original was a dot_file)
        #
        #
        #
        #
        #
        #
        # _dirname, _basename, _ext = self.dirname_and_basename_and_ext
        # debugger if _basename =~ "hello"
        # ext_val = ext_val.to_s
        #
        # # 1) Only perform if the extension match the one given (or was a blank ext given?)
        #
        #
        #
        # new_path = @path.clone
        #
        # current_ext = self.ext
        #
        # e = e.to_s
        #
        # if e.fwf_present?
        #   new_path.gsub!( /\.#{e}$/, "" )
        #   result = self.gsub(/#{ not_beginning_of_line_or_separator}\.#{self.ext}$/, '')
        # else
        #   self.clone
        # end
        #
        # self.class.new( new_path )
      end

      # Two separate modes.  With no arguments given, returns the current extension as a string (not a filepath)
      # With an argument, returns the path with a .(arg) tacked onto the end.  The leading period is wholly optional.
      # Does not return a filepath.
      # Does not include leading period
      def ext( *args )
        if args.length == 0
          split_basename = self.basename.to_s.split(".")
          split_basename.length > 1 ? split_basename.last : ""
        else
          
          append_to_path = args.compact.map{ |ex|
            ex.to_s.gsub( /^\./, '' )
          }.compact.join( "." )
          
          appended_to_path = "." + "#{append_to_path}" unless append_to_path.fwf_blank?
          
          self.class.new( "#{@path}#{appended_to_path}" )
        end
      end
      
      def ext?( e )
        e.to_str == self.ext
      end

      # base, ext =  @path.basename_and_ext
      def basename_and_ext
        [self.basename_no_ext, self.ext]
      end



      def dirname_and_basename
        warn("FilePath#dirname_and_basename() is deprecated.  Pathname#split() already existed, and should be used instead.")
        [self.dirname, self.basename]
      end

      def dirname_and_basename_and_ext
        [self.dirname, self.basename_no_ext, self.ext]
      end

      # if it's a file, returns the immediate parent directory.
      # if it's not a file, returns itself
      def directory
        self.directory? ? self : self.dirname
      end

      def original?
        !self.symlink?
      end

      def original
        self.symlink? ? self.readlink.original : self
      end

      # Basically Pathname.relative_path_from, but you can pass in strings
      def relative_path_from( dir )
        dir = super( Pathname.new( dir ) )
        self.class.new( dir )
      end

      def fwf_filepath( &block )
        yield self if block_given?
        self
      end
      
      # Making this stricter, and failing when the formatting doesn't meet expectations, rather than 
      # guessing wildly about what to do on corner cases.
      # 
      # This file is part of a sequence of files (file.000001.txt, file.000002.txt, file.000003.txt, etc.)
      # `succ()` gives you the next file in the sequence.  If no counter is present, a counter is 
      # added (file.dat --> file.000000.dat)
      #
      # You can change the length of the sequence string by passing in the `digit_count` argument.
      # Changing the length for a given sequence will lead to the function not recognizing the existing
      # counter, and installing a new one after it.
      def succ( digit_count: SUCC_DIGIT_COUNT )
        directory_pieces = self.split
        succession_basename = Utils::Succession.get_successor_name( directory_pieces.pop, digit_count )
        
        return FilePath.new( * directory_pieces ) / succession_basename
      end
      
      
      def timestamp( format: :default, time: Time.now, splitter: ".", &block )
        timestamped_basename = Utils::Timestamp.timestamp( self.basename, format: format, time: time, splitter: splitter )
        
        directory_path = self.split[0..-2]
        
        # sigh....
        if directory_path.first.path == "." && self.path[0..1] != ".#{File::SEPARATOR}"
          directory_path.shift
        end
        
        if directory_path.length == 0
          timestamped_file = timestamped_basename.fwf_filepath
        else
          timestamped_file = FilePath.new( * self.split[0..-2], timestamped_basename ) 
        end
        
        _yield_and_return( timestamped_file, &block )
      end
      
      # puts a string between the main part of the basename and the extension
      # or after the basename if there is no extension.  Used to describe some
      # file variant.
      # 
      # Example "/home/docs/my_awesome_screenplay.txt".fwf_filepath.specifier("final_draft")
      #  => FunWith::Files::FilePath:/home/docs/my_awesome_screenplay.final_draft.txt
      #
      # For the purposes of this method, anything after the last period in the filename
      # is considered the extension.
      def specifier( str, &block )
        str = str.to_s
        chunks = self.to_s.split(".")

        if chunks.length == 1
          chunks << str
        else
          chunks = chunks[0..-2] + [str] + [chunks[-1]]
        end

        f = chunks.join(".").fwf_filepath
        _yield_and_return( f, &block )
      end
      
      # Returns the "wildcarded" version of the filename, suitable for finding related files
      # with similar timestamps.  
      #
      # TODO: succession : enumerates a sequence of files that get passed
      # to a block in order.
      def succession( opts = { digit_count: SUCC_DIGIT_COUNT, timestamp: false } )
        if opts[:timestamp]
          opts[:timestamp_format] ||= "%Y%m%d%H%M%S%L"
          timestamp = Time.now.strftime( opts[:timestamp_format] )
          digit_count = timestamp.length
        else
          timestamp = false
          digit_count = opts[:digit_count]
        end

        chunks = self.basename.to_s.split(".")
        glob_stamp_matcher = '[0-9]' * digit_count

        # unstamped filename, no extension
        if chunks.length == 1
          original = chunks.first
          stamped = [original, glob_stamp_matcher].join(".")
        # stamped filename, no extension
        elsif chunks[-1].match( /^\d{#{digit_count}}$/ )
          original = chunks[0..-2].join(".")
          stamped = [original, glob_stamp_matcher].join(".")
        # stamped filename, has extension
        elsif chunks[-2].match( /^\d{#{digit_count}}$/ )
          original = [chunks[0..-3], chunks.last].flatten.join(".")
          stamped = [chunks[0..-3], glob_stamp_matcher, chunks.last].join(".")
        # unstamped filename, has extension
        else
          original = chunks.join(".")
          stamped = [ chunks[0..-2], glob_stamp_matcher, chunks[-1] ].flatten.join(".")
        end

        [self.dirname.join(original), self.dirname.glob(stamped)].flatten
      end



      # TODO: succ_last : find the last existing file of the given sequence.
      # TODO: succ_next : find the first free file of the given sequence

      def load
        if self.directory?
          self.glob( :recursive => true, :ext => "rb" ).map(&:load)
        else
          Kernel.load( self.expand )
        end
      end

      # Require ALL THE RUBY!
      # This may be a bad idea...
      #
      # Sometimes it fails to require a file because one of the necessary prerequisites
      # hasn't been required yet (NameError).  requir catches this failure and stores
      # the failed requirement in order to try it later.  Doesn't fail until it goes through
      # a full loop where none of the required files were successful.
      def requir
        FunWith::Files::Requirements::Manager.require_files( self )
      end
      
      def root?
        self == self.up
      end

      def descend( &block )
        path = self.clone

        if path.root?
          yield path
        else
          self.up.descend( &block )
          yield self
        end
      end

      def ascend( &block )
        path = self.clone

        if path.root?
          yield path
        else
          yield self
          self.up.ascend( &block )
        end
      end

      def to_pathname
        Pathname.new( @path )
      end

      # TODO :  Not working as intended.
      # def separator( s = nil )
      #   # If s is nil, then we're asking for the separator
      #   if s.nil?
      #     @separator || File::SEPARATOR
      #   else
      #     @separator = s
      #   end
      #   # otherwise we're installing a separator
      # end
      def separator
        File::SEPARATOR
      end

      protected
      # TODO: Need a separate API for user to call
      def _must_be_a_file
        unless self.file?
          calling_method = caller[0][/`.*'/][1..-2]
          raise Errno::EACCES.new( "Can only call FunWith::Files::FilePath##{calling_method}() on an existing file.")
        end
      end

      def _must_be_a_directory
        unless self.directory?
          calling_method = caller[0][/`.*'/][1..-2]
          raise Errno::EACCES.new( "Can only call FunWith::Files::FilePath##{calling_method}() on an existing directory." )
        end
      end

      def _must_be_writable
        unless self.writable?
          calling_method = caller[0][/`.*'/][1..-2]
          raise Errno::EACCES.new( "Error in FunWith::Files::FilePath##{calling_method}(): #{@path} not writable." )
        end
      end
      
      # Simplifies some of the block-formed methods
      def _yield_and_return( obj = self, &block )
        yield obj if block_given?
        obj
      end
    end
  end
end