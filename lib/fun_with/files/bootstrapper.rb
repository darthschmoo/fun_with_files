module FunWith
  module Files
    class Bootstrapper
      def self.bootstrap
        self.new.bootstrap
      end
      
      def bootstrap
        load_core_extensions
        install_minimal_requir_functionality
        run_requir
        rootify
        add_filepath_class_methods
        extend_gem_api
      end
      
      protected
      # gets all the core-extending modules from fun_with/files/core_extensions and uses them to
      # beef up the core classes
      def load_core_extensions
        for file in Dir.glob( File.join( __dir__, "core_extensions", "*.rb" ) )
          # remove trailing extension to make it require-friendly.
          file = file.gsub(/\.rb$/,'')
          
          require_relative file
          
          # convert filename into class name
          target_class_str = filename_to_class_name( file )
          
          # get the core class that needs extending, and the 
          target_class = Kernel.const_get( target_class_str )
          mixin_class  = Kernel.const_get( "FunWith::Files::CoreExtensions::#{target_class_str}" )
          
          target_class.send( :include, mixin_class )
        end
      end
      
      def install_minimal_requir_functionality
        for fil in %w( file_path
                       string_behavior
                       file_manipulation_methods
                       file_permission_methods
                       digest_methods
                       file_requirements
                       requirements/manager
                       stat_methods )
          require_relative fil
        end

        # These have some FilePath methods required by .requir()
        for mod in [ FunWith::Files::StringBehavior,
                     FunWith::Files::FileManipulationMethods, 
                     FunWith::Files::FilePermissionMethods, 
                     FunWith::Files::DigestMethods,
                     FunWith::Files::FileRequirements,
                     FunWith::Files::StatMethods ]
          FunWith::Files::FilePath.send( :include, mod )
        end
      end
      
      def run_requir
        lib_dir = __dir__.fwf_filepath.up
        
        # And requir() everything else
        lib_dir.requir
      end
      
      def rootify
        root_dir = __dir__.fwf_filepath.up.up.up
        FunWith::Files::RootPath.rootify( FunWith::Files, root_dir )
      end
      
      def add_filepath_class_methods
        FunWith::Files::FilePath.extend( FunWith::Files::FilePathClassMethods )
      end
      
      def extend_gem_api
        FunWith::Files.extend( FunWith::Files::GemAPI )
      end
      
      
      def filename_to_class_name( str )
        File.basename( str ).split( "_" ).map(&:capitalize).join("")
      end
    end
  end
end