#!/usr/bin/ruby
require 'mcbuild'

libs = [
	$com_oreisoft_mylib
]

$com_oreisoft_myapp = MCBuild.new(File.dirname(__FILE__))
	.set_name("myapp")
	.set_dependency(libs)
