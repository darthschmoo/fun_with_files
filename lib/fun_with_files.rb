require 'xdg'
require 'digest'      # stdlib
require 'pathname'    # stdlib
require 'tmpdir'      # Dir.tmpdir


for fil in ["string", "array", "false", "hash", "nil", "object"]
  require_relative File.join( "fun_with", "files", "core_extensions", fil )
end

for klass in ["String", "Object", "NilClass", "Hash", "FalseClass", "Array"]
  Kernel.const_get(klass).send( :include, FunWith::Files::CoreExtensions.const_get(klass))  
end


for fil in ["file_path", "string_behavior", "file_manipulation_methods", "file_permission_methods", "digest_methods", "file_requirements"]
  require_relative File.join( "fun_with", "files", fil )
end


# These have some FilePath methods required by .requir()
for mod in [ FunWith::Files::StringBehavior,
             FunWith::Files::FileManipulationMethods, 
             FunWith::Files::FilePermissionMethods, 
             FunWith::Files::DigestMethods,
             FunWith::Files::FileRequirements ]
  FunWith::Files::FilePath.send( :include, mod )
end

lib_dir = File.dirname(__FILE__).fwf_filepath( "fun_with" )

# And requir() everything else
lib_dir.requir

FunWith::Files::RootPath.rootify( FunWith::Files, __FILE__.fwf_filepath.dirname.up )
FunWith::Files::FilePath.extend( FunWith::Files::FilePathClassMethods )

FunWith::Files.extend( FunWith::Files::GemAPI )
