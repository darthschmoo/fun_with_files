module FunWith
  module Files
    module Requirements
      class Manager
        def self.require_files( path )
          self.new( path ).require_files
        end
        
        def initialize( path )
          case path
          when Array
            @required_files = path
          when FilePath
            if path.directory?
              @required_files = path.glob( :recursive => true, :ext => "rb" )
            else
              @required_files = [path]
            end
          end
          
          @required_files.map!{|f| f.expand.gsub( /\.rb$/, '' ) }
          @successfully_required = []
          @missing_constants = {}
        end
        
        def require_files
          while @required_files.length > 0
            file = @required_files.shift
            
            if try_requiring_file( file )
              check_for_needed_constants
            end
          end
          
          # Ran into a situation where it was failing because the missing constant was incorrectly being guessed
          # to be M1::M2::M3::M4 instead of M1::M2::M4.  Had the file been required, it would have gone through.
          # So I'm adding a last-chance round, using the ugly old approach of simply trying to require everything
          # over and over again until it's clear no progress ins being made.
          unless @missing_constants.fwf_blank?
            unless require_files_messily( @missing_constants.values.flatten )
              raise NameError.new( "The following constants could not be defined: #{@missing_constants.inspect}")
            end
          end
        end
        
        # If it's not the sort of error we're looking for, re-raise the error
        def uninitialized_constant_error( e, &block )
          if e.message =~ /^uninitialized constant/
            yield
          else
            raise e
          end
        end
          
        def try_requiring_file( file )
          begin
            require file
            @successfully_required << file
            true
          rescue NameError => e
            uninitialized_constant_error( e ) do
              konst = e.message.split.last
              
              @missing_constants[konst] ||= []
              @missing_constants[konst] << file
              false
            end
          end
        end
        
        def check_for_needed_constants
          for konst, files in @missing_constants
            if Object.const_defined?( konst )
              @required_files = files + @required_files    
              @missing_constants.delete( konst )
            end
          end
        end
        
        # returns true if all the files given got required
        def require_files_messily( files )
          while true
            files_remaining = files.length
            return true if files_remaining == 0
            
            files.length.times do
              begin
                file = files.shift
                require file
                @successfully_required << file
              rescue NameError => e
                uninitialized_constant_error( e ) do
                  files.push( file )
                end
              end
            end
            
            return false if files.length == files_remaining
          end
        end
      end
    end
  end
end
