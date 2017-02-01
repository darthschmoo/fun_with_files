module FunWith
  module Files
    
    # Describes a domain-specific language for creating and populating a
    # directory of files.
    class DirectoryBuilder
      attr_accessor :current_path
      
      def initialize( path )
        @paths = []
        @current_path = path.fwf_filepath
        @current_file = nil
        make_path
      end
      
      def self.create( path, &block )
        builder = self.new( path )
        yield builder if block_given?
        builder
      end

      def dir( *args, &block )
        descend( *args ) do
          yield if block_given?
        end
      end
      
      # Beware: if block is given, the temp directory will be
      #
      def self.tmpdir( &block )
        if block_given?
          FilePath.tmpdir do |dir|
            self.create( dir ) do |builder|
              yield builder
            end
          end
        else
          self.create( FilePath.tmpdir )
        end
      end
      
      # Copies the given source file into a file in the current_path.
      # If a dest_name is given, the new file will be given that name.
      def copy( src_filepath, dst_name = nil )
        dst_filepath = dst_name ? @current_path.join( dst_name ) : @current_path
        FileUtils.copy( src_filepath, dst_filepath )
      end
      
      def file( name = nil, content = nil, &block )
        # if name && content
        #   begin
        #     f = open_file( name )
        #     f << content
        #   ensure
        #     close_file
        #   end
        if name
          open_file( name )
          @current_file << content if content
          if block_given?
            begin
              yield @current_file
            ensure
              close_file
            end
          end
        else
          @current_file
        end
      end
      
      attr_reader :current_file
      
      def current_file=( file )
        @current_file = file.fwf_filepath
      end
      
      # def current_file
      #   @current_file ? FunWith::Files::FilePath.new( @current_file.path ) : nil
      # end
      
      # if file not given, the result is appended to the current file.
      def download( url, file = nil, opts = {} )
        if file
          if file.fwf_filepath.relative?
            file = FunWith::Files::FilePath.new( @current_path, file )
          end
            
          File.open( file, "w" ) do |f|
            download_to_target( url, f )
          end
        elsif @current_file
          download_to_target( url, @current_file, opts )
        else
          puts "No current file to append #{url} to."
        end
      end
      
      def template( *args )
        raise "DirectoryBuilder cannot use template() function.  require 'fun_with_templates' to enable."
      end

      protected
      def make_path
        FileUtils.mkdir_p( @current_path ) unless @current_path.exist?
      end

      def descend( *args, &block )
        if @current_path.directory?
          close_file
  	      @paths << @current_path
          @current_path = @paths.last.join( *args )
          make_path
  	      yield
          @current_path = @paths.pop
          close_file
        else
          raise "Cannot descend."
        end
      end 
      
      def open_file( name )
        close_file
        @current_file = File.open( @current_path.join( name ), "w" )
      end
      
      def close_file
        if @current_file
          @current_file.flush
          @current_file.close
        end
        
        @current_file = nil
      end
      
      def download_to_target( url, file, signatures = {} )
        Downloader.new.download( url, file, signatures )
      end
    end
  end
end

