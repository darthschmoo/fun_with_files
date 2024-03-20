require 'xdg'
require 'digest'      # stdlib
require 'pathname'    # stdlib
require 'set'
require 'tmpdir'      # Dir.tmpdir

require 'debug'

require_relative 'fun_with/files/bootstrapper'
# sets up everything needed to load .requir(), which loads everything else
FunWith::Files::Bootstrapper.bootstrap

