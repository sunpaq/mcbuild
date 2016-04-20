#!/usr/bin/ruby
require 'mcbuild'

b = MCBuild.new('.')
b.prepare
b.compile
b.archive_exe('hello_world')
