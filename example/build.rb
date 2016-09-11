#!/usr/bin/ruby
require 'mcbuild'

require './mylib/settings.rb'
require './myapp/settings.rb'

MCBuild.waitArg('clean') do
	$com_oreisoft_mylib.clean
	$com_oreisoft_myapp.clean
end

MCBuild.waitArg('all') do
	$com_oreisoft_mylib.info.compile.archive_lib
	$com_oreisoft_myapp.info.compile.archive_exe.done
end

MCBuild.waitArg('run') do
	$com_oreisoft_myapp.run
end

MCBuild.printArgs(['clean', 'all', 'run'])
