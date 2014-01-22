module FunWith
  module Files
    class FilePath < Pathname
      def initialize( *args )
        super( File.join( *args ) )
      end

      # args implicitly joined to cwd
      def self.cwd( *args )
        Dir.pwd.fwf_filepath.join( *args )
      end
      
      def self.pwd( *args )
        self.cwd( *args )
      end
      
      def self.tmpdir( &block )
        if block_given?
          Dir.mktmpdir do |d|
            yield d.fwf_filepath
          end
        else
          Dir.mktmpdir.fwf_filepath
        end
      end

      def self.home( *args )
        Dir.home.fwf_filepath.join( *args )
      end

      def join( *args, &block )
        if block_given?
          yield self.class.new( super(*args) )
        else
          self.class.new( super(*args) )
        end
      end

      alias :exists? :exist?
      
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
      #    :class  =>  [self.class] The class of objects you want returned (String, FilePath, ClassLoader, etc.)
      #                Should probably be a subclass of FilePath or String.  Class.initialize() must accept a string
      #                [representing a file path] as the sole argument.
      #
      #    :recurse => [false] 
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
      def glob( *args )
        opts = args.last.is_a?(Hash) ? args.pop : {}
        
        flags = case opts[:flags]
        when NilClass
          0
        when Array      # should be an array of integers
          opts[:flags].inject(0) do |memo, obj|
            memo | obj
          end
        when Integer
          opts[:flags]
        end
        
        flags |= File::FNM_DOTMATCH if opts[:dots]
        flags |= File::FNM_CASEFOLD if opts[:sensitive]
        
        if args.first == :all
          args = ["**", "*"]
        else
          recurser = (opts[:recurse] || opts[:recursive]) ? "**" : nil
          extensions = case opts[:ext]
          when Symbol, String
            "*.#{opts[:ext]}"
          when Array
            extensions = opts[:ext].map(&:to_s).join(',')
            "*.{#{extensions}}"
          when NilClass
            nil
          end
          
          args += [recurser, extensions]
          args.compact!
        end
        
        opts[:class] ||= self.class
        
        files = Dir.glob( self.join(*args), flags ).map{ |f| opts[:class].new(f) }
        files.reject!{ |f| f.basename.to_s.match(/^\.{1,2}$/) } unless opts[:parent_and_current]
        files
      end
      
      def expand
        self.class.new( File.expand_path( self ) )
      end

      # Raises error if self is a file and args present.
      # Raises error if the file is not accessible for writing, or cannot be created.
      # attempts to create a directory
      def touch( *args )
        raise "Cannot create subdirectory to a file" if self.file? && args.length > 0
        touched = self.join(*args)
        dir_for_touched_file = case args.length
          when 0
            self.up
          when 1
            self
          when 2..Infinity
            self.join( *(args[0..-2] ) )
          end
        
        self.touch_dir( dir_for_touched_file ) unless dir_for_touched_file.directory?
        FileUtils.touch( touched )
        return touched
      end
      
      def touch_dir( *args, &block )
        touched = self.join(*args)
        if touched.directory?
          FileUtils.touch( touched )    # update access time
        else
          FileUtils.mkdir_p( touched )  # create directory (and any needed parents)
        end
        
        yield touched if block_given?
        return touched
      end
      
      def write( content = nil, &block )
        File.open( self, "w" ) do |f|
          f << content if content
          if block_given?
            yield f
          end
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
      
      def grep( regex )
        return [] unless self.file?
        matching = []
        self.each_line do |line|
          matching.push( line ) if line.match( regex )
        end
        matching
      end

      # Not the same as zero?
      def empty?
        raise Exceptions::FileDoesNotExist unless self.exist?
        
        if self.file?
          File.size( self ) == 0
        elsif self.directory?
          self.glob( "**", "*" ).length == 0
        end
      end
            
      # Does not return a filepath
      def basename_no_ext
        self.basename.to_s.split(".")[0..-2].join(".")
      end
      
      def without_ext
        self.gsub(/\.#{self.ext}$/, '')
      end
      
      # Does not return a filepath.
      # Does not include leading period
      def ext
        split_basename = self.basename.to_s.split(".")
        split_basename.length > 1 ? split_basename.last : ""
      end
      
      # base, ext =  @path.basename_and_ext
      def basename_and_ext
        [self.basename_no_ext, self.ext]
      end
      
      def dirname_and_basename
        [self.dirname, self.basename]
      end
      
      def dirname_and_basename_and_ext
        [self.dirname, self.basename_no_ext, self.ext]
      end
      
      # Basically Pathname.relative_path_from, but you can pass in strings
      def relative_path_from( dir )
        dir = super( Pathname.new( dir ) )
        self.class.new( dir )
      end

    
      def fwf_filepath
        self
      end
      
      # Gives a sequence of files.  Examples:
      # file.dat --> file.000000.dat
      # file_without_ext --> file_without_ext.000000
      # If it sees a six-digit number at or near the end of the
      # filename, it increments it.
      #
      # You can change the length of the sequence string by passing
      # in an argument, but it should always be the same value for
      # a given set of files.
      SUCC_DIGIT_COUNT = 6
      def succ( opts = { digit_count: SUCC_DIGIT_COUNT, timestamp: false } )
        if opts[:timestamp]
          timestamp = Time.now.strftime("%Y%m%d%H%M%S%L")
          digit_count = timestamp.length
        else
          timestamp = false
          digit_count = opts[:digit_count]
        end
        
        chunks = self.basename.to_s.split(".")
        # not yet sequence stamped, no file extension.
        if chunks.length == 1
          if timestamp
            chunks.push( timestamp )
          else
            chunks.push( "0" * digit_count )
          end
        # sequence stamp before file extension
        elsif match_data = chunks[-2].match( /^(\d{#{digit_count}})$/ )
          if timestamp
            chunks[-2] = timestamp
          else
            i = match_data[1].to_i + 1
            chunks[-2] = sprintf("%0#{digit_count}i", i)
          end
        # try to match sequence stamp to end of filename
        elsif match_data = chunks[-1].match( /^(\d{#{digit_count}})$/ )
          if timestamp
            chunks[-1] = timestamp
          else
            i = match_data[1].to_i + 1
            chunks[-1] = sprintf("%0#{digit_count}i", i)
          end
        # not yet sequence_stamped, has file extension
        else
          chunks = [chunks[0..-2], (timestamp ? timestamp : "0" * digit_count), chunks[-1]].flatten
        end

        self.up.join( chunks.join(".") )
      end
    
    
      # TODO: succession : enumerates a sequence of files that get passed
      # to a block in order.
      def succession( opts = { digit_count: SUCC_DIGIT_COUNT, timestamp: false } )
        if opts[:timestamp]
          timestamp = Time.now.strftime("%Y%m%d%H%M%S%L")
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
      
        [self.dirname.glob(original), self.dirname.glob(stamped)].flatten
      end


    
      # TODO: succ_last : find the last existing file of the given sequence.
      # TODO: succ_next : find the first free file of the given sequence
    
    
      # File manipulation
      def rename( filename )
      
      end
    
      def rename_all( pattern, gsubbed )
      
      end

      def rm( secure = false )
        if self.file?
          FileUtils.rm( self )
        elsif self.directory?
          FileUtils.rmtree( self )
        end
      end

      
      def load
        if self.directory?
          self.glob( :recursive => true, :ext => "rb" ).map(&:load)
        else
          Kernel.load( self.expand )
        end
      end
      
      
      def requir
        if self.directory?
          self.glob( :recursive => true, :ext => "rb" ).map(&:requir)
        else
          require self.expand.gsub( /\.rb$/, '' )
        end
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
    end
  end
end