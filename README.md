# mcbuild

##### this is an ruby library help you build C/C++/Monk-C projects
##### without writing Makefile. It works on Unix systems (Mac/BSD/Linux)
##### (What is Monk-C? https://github.com/sunpaq/monkc)

### 1. Ruby vs Makefile

	the C programming language and make/gmake tool is great
	but many C newbie find Makefile hard to wirte. 
	
	many of them stop learning C programming just because 
	they can't organize their code and build a executable easily.
	the syntax of Makefile looks strange for new programmers these days.
	and these syntax is only used in Makefiles.
	
	ruby is easy to learn. and also can be used on many other tasks.
	mcbuild is quite simple. you don't need to know ruby before. 
	

### 2. install from official rubygem

    gem install mcbuild

### 3. install from this git repo

	git clone https://github.com/sunpaq/mcbuild.git
	cd mcbuild
	
	gem build   mcbuild.gemspec
	sudo gem install mcbuild-x.x.x.gem
    
    or 
    
    chmod +x test_gem.sh && ./test_gem.sh

### 4. simple usage example

    please read the settings.rb & build.rb scripts in example folder
    
    settings.rb 
    	doesn't do any build action, only set build blocks relationship.
    	
    build.rb 
    	catch the user input and call the compile & archive actions.

### 5. headers of each script

	#!/usr/bin/ruby
    require 'mcbuild'
    
### 6. project structure

	- root
		build.rb
		- lib
			settings.rb
			build.rb (optional)
		- app
			settings.rb
			build.rb (optional)
			
### 7.1 [settings.rb] create build block

	$com_global_name = MCBuild.new('./the/block/path')
	
	notice:
	1. use a global var '$var' with underbar '_' separated reverse domain name
	2. avoid use related path, use 'File.dirname(__FILE__)' get absolute path
	
### 7.2 [settings.rb] config build block

	$com_global_name = MCBuild.new('./the/block/path')
		.set_name("myapp")
		.set_dependency([
			$com_global_lib1, 
			$com_global_lib2])
			
	notice:
	1. use nested setters syntax $block.set_A().set_B().set_C()
	2. if name is not setted, lib/exec will named 'mcdefault' by default
	3. the static lib will rename to 'lib'+name+'.a'
	   it is a standard convention of C compiler
	4. set_dependency() need a array
	   use '[$lib1]' even if only one lib needed

### 8.1 [build.rb] compile & clean

	$com_global_name.compile
	$com_global_name.clean

### 8.2 [build.rb] archive

    $com_global_lib1.archive_lib
    $com_global_app.archive_exe
    
### 8.3 [build.rb] user input

    MCBuild.waitArg('clean') do
    	$com_global_lib1.clean
    	$com_global_app.clean
    end
    
### 8.4 [build.rb] print script usage info

	MCBuild.printArgs(['clean', 'build', 'run'])
	

		
		
    
