#!/usr/bin/ruby
require 'mcbuild'

build = MCBuild.new(__dir__).include ['mylib', 'myapp']

build.command 'clean' do
	$com_oreisoft_mylib.clean
	$com_oreisoft_myapp.clean
end

build.command 'all' do
	$com_oreisoft_mylib.info.compile.archive_lib
	$com_oreisoft_myapp.info.compile.archive_exe.done
end

build.command 'run' do
	$com_oreisoft_myapp.run
end

build.print ['clean', 'all', 'run']
