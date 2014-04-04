require 'digest/md5'
require 'pathname'  #stdlib
require 'tmpdir'

for file in Dir.glob( File.join( File.dirname(__FILE__), "files", "**", "*.rb" ) ).map{ |f| f.gsub(/\.rb$/, '') }
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
