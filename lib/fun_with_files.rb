require 'digest/md5' # stdlib
require 'pathname'   # stdlib
require 'tmpdir'
require 'fun_with_testing'

files = Dir.glob( File.join( File.dirname(__FILE__), "fun_with", "**", "*.rb" ) )

for file in files.map{ |f| f.gsub(/\.rb$/, '') }
  require file
end

FunWith::Files::RootPath.rootify( FunWith::Files, __FILE__.fwf_filepath.dirname.up )

module FunWith
  module Files
    class FilePath
      for mod in [ StringBehavior,
                   FileManipulationMethods,
                   FilePermissionMethods,
                   DigestMethods ]
        include mod
      end
    end
  end
end
