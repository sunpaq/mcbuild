#!/usr/bin/ruby
require 'mcbuild'

$com_oreisoft_mylib = MCBuild.new(File.dirname(__FILE__))
	.set_name("mylib")