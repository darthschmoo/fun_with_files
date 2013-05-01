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
          recurser = opts[:recurse] ? "**" : nil
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
      
      # given an ancestor dir, returns a relative path that takes you from
      # the ancestor dir to the pathfile.  TODO: expand to arbitrary paths, not
      # just immediate ancestors.  For example "/usr/bin/bash".relative_to("/usr/bin/zsh") => "." ?
      # TODO:  look at Pathname.relative_path_from.  Might just want to alias.
      def relative_to( ancestor_dir )
        depth = ancestor_dir.to_s.split(File::SEPARATOR).length
        relative_path = self.to_s.split(File::SEPARATOR)
        relative_path[(depth)..-1].join(File::SEPARATOR).fwf_filepath
      end
      
      # gsub acts on the filepath, not the file contents
      def gsub( *args )
        self.to_s.gsub(*args).fwf_filepath
      end
      
      def gsub!( *args )
        new_path = self.to_s.gsub(*args)
        self.instance_variable_set(:@path, new_path)
      end
    
      def fwf_filepath
        self
      end
    end
  end
end