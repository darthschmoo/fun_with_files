require 'xdg'
require 'digest'      # stdlib
require 'pathname'    # stdlib
require 'tmpdir'      # Dir.tmpdir

files = Dir.glob( File.join( File.dirname(__FILE__), "fun_with", "**", "*.rb" ) )

for file in files.map{ |f| f.gsub(/\.rb$/, '') }
  require file
end

FunWith::Files::RootPath.rootify( FunWith::Files, __FILE__.fwf_filepath.dirname.up )

module FunWith
  module Files
    class FilePath
      for moduul in [ StringBehavior,
                      FileManipulationMethods,
                      FilePermissionMethods,
                      DigestMethods ]
        include moduul
      end
    end
  end
end

FunWith::Files::FilePath.extend( FunWith::Files::FilePathLocationMethods )
