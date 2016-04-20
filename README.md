# mcbuild

#### this is an ruby library help you build C/C++/Monk-C projects
#### without writing Makefile

# install

    gem install mcbuild
    
# simple usage example (create a build.rb<any name> file at root folder of C project)

    require 'mcbuild'
    
    b = MCBuild.new('.')
    b.prepare
    b.compile
    b.archive_exe('hello_world')

#### after given the build.rb file execute permission (chmod +x build.rb)
#### you can run it by: ruby build.rb
#### then an '_build' folder will created
#### executable file place into '_build/archive' with name 'hello_world'

# archive the .a static library

    b.archive_lib('libhello.a')

# copy header files into _build/archive folder

    b.copy_headers(["file1.h", "file2.h"])
    
# reference other project build by mcbuild

    b.prepare(["../lib1/_build/archive", "../lib2/_build/archive"], ["lib1", "lib2"])
    
