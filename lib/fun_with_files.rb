require 'xdg'
require 'digest'      # stdlib
require 'pathname'    # stdlib
require 'tmpdir'      # Dir.tmpdir


for fil in ["string", "array", "false", "hash", "nil", "object"]
  require_relative File.join( "fun_with", "files", "core_extensions", fil )
end

for fil in ["file_path", "string_behavior", "file_manipulation_methods", "file_permission_methods", "digest_methods"]
  require_relative File.join( "fun_with", "files", fil )
end

# These have some FilePath methods required by .requir()
for moduul in [ FunWith::Files::StringBehavior,
                FunWith::Files::FileManipulationMethods, 
                FunWith::Files::FilePermissionMethods, 
                FunWith::Files::DigestMethods ]
  FunWith::Files::FilePath.send( :include, moduul )
end

lib_dir = File.join( File.dirname(__FILE__), "fun_with" ).fwf_filepath

# And requir() everything else
lib_dir.requir

FunWith::Files::RootPath.rootify( FunWith::Files, __FILE__.fwf_filepath.dirname.up )
FunWith::Files::FilePath.extend( FunWith::Files::FilePathClassMethods )
