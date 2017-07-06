#!/usr/bin/ruby
require 'mcbuild'

$com_oreisoft_myapp = MCBuild.new(__dir__)
	.set_name("myapp")
	.set_dependency([$com_oreisoft_mylib])
