# coding: utf-8

module Dtconv
  VERSION = "0.4.0"
  
  module_path = File.expand_path(File.dirname(__FILE__))
  $LOAD_PATH.push(module_path)
  MODULE_PATH = module_path
end

if $0 == __FILE__
  require 'dtconv/cli'
  cli = Dtconv::Cli.new
  cli.main(ARGV)
  
end



# EOF
