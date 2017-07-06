#!/usr/bin/ruby
require 'mcbuild'

libs = [
	$com_oreisoft_mylib
]

$com_oreisoft_myapp = MCBuild.new(__dir__)
	.set_name("myapp")
	.set_dependency(libs)
