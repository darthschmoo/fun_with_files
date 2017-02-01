require 'xdg'
require 'digest'      # stdlib
require 'pathname'    # stdlib
require 'tmpdir'      # Dir.tmpdir


# Do the bare minimum to get FilePath.requir working
# file_path = File.join( "fun_with", "files", "file_path" )
# string_behavior = File.join( "fun_with", "files", "string_behavior" )
#
#
# require_relative file_path
# require_relative string_behavior
#
# FunWith::Files::FilePath.send( :include, FunWith::Files::StringBehavior )
# FunWith::Files::FilePath.new( "fun_with" ).requir
#
# debugger



core_extension_folder = File.join( "lib", "fun_with", "files", "core_extensions" )

for fil in Dir.glob( File.join( core_extension_folder, "*.rb" ) )
  # Dir.glob targets the root directory, while require_relative is relative to lib/,
  # so the [4..-4] removes the leading lib/ and the trailing extension to make it
  # require_relative-friendly.
  require_path = fil[4..-4]   # 
  basename = File.basename( fil )[0..-4]
  # debugger if basename =~ /class/
  
  target_class_str = basename.split( "_" ).map(&:capitalize).join("")
  target_class = Kernel.const_get( target_class_str )
  mixin_class_str  = "FunWith::Files::CoreExtensions::#{target_class_str}"

  # puts "Basename: #{basename}"
  # puts "Mixin: " + mixin_class_str.inspect
  # puts "Target: #{target_class}"
  # puts "requiring: #{require_path}"
  require_relative require_path
  mixin_class = Kernel.const_get( mixin_class_str )
  # puts mixin_class.to_s
  
  target_class.send( :include, mixin_class )
end



# for fil in ["string", "array", "false", "hash", "nil", "object",]
#   require_relative File.join( "fun_with", "files", "core_extensions", fil )
# end
#
# for klass in ["String", "Object", "NilClass", "Hash", "FalseClass", "Array", "Set"]
#   puts klass
#   debugger if klass == "Set"
#   Kernel.const_get(klass).send( :include, FunWith::Files::CoreExtensions.const_get(klass))
# end
#

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
