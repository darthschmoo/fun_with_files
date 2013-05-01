require 'pathname'  #stdlib
require 'tmpdir'
require 'debugger'


require_relative File.join("files", "file_path")
require_relative File.join("files", "root_path")
require_relative File.join("files", "remote_path")
require_relative File.join("files", "string_extensions")

FunWith::Files::RootPath.rootify( FunWith::Files, FunWith::Files::FilePath.new(__FILE__).dirname.up )

