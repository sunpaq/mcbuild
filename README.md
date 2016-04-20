# mcbuild

create an build.rb file in root of source code 

require 'mcbuild' at first line. 
then use MCBuild class 

build = MCBuild.new('.') 
build.prepare 
build.copy_headers 
build.compile 
build.archive_exe
