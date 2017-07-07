#!/usr/bin/ruby
require 'find'
require 'fileutils'

class MCTarget
	def self.RaspberryPi2
		#'armv7l-unknown-linux-gnueabihf'
		'arm-eabi -marm -mfpu=vfp -mcpu=arm1176jzf-s -mtune=arm1176jzf-s -mfloat-abi=hard'
	end

	def self.MacOS
		'x86_64-apple-darwin'
	end
end

class MCConfig
	def self.support_machines
		['x86_64', 'armv6', 'armv7', 'armv7s', 'arm64']
	end

	def self.x86_64
		'x86_64'
	end

	def self.armv6
		'armv6'
	end

	def self.armv7
		'armv7'
	end

	def self.armv7s
		'armv7s'
	end

	def self.arm64
		'arm64'
	end

	def self.c89
		'c89'
	end

	def self.c99
		'c99'
	end
end

class MCBuild
	def self.detect_machine
		ret = MCConfig.x86_64
		mach = %x[uname -m].strip
		MCConfig.support_machines.each { |supportm|
			if mach.include? supportm
				ret = supportm
			end
		}
		ret
	end

	def self.detect_machine_macro
		"-D__"+MCBuild.detect_machine+"__"
	end

	def self.no_command(valid_args)
		ARGV.each { |arg|
			valid_args.each { |va|
				if va == arg
					return
				end
			}
		}
		yield valid_args
	end

	def print(valid_args)
		ARGV.each { |arg|
			valid_args.each { |va|
				if va == arg
					return
				end
			}
		}
		puts "usage:"
		valid_args.each { |arg|
			puts "./build.rb #{arg}"
		}
		self
	end
 
	def command(arg)
		ARGV.each do |_arg|
			if _arg==arg
				yield
			end
		end
		self
	end

	def self.clean(path)
		begin
			FileUtils.rm_rf(path)
		rescue Exception => e
			puts e
		end
	end

	def include(folders)
		folders.each { |f|
			require_relative @d+'/'+f+'/settings.rb'
		}
		self
	end

	#remove the last slash from path
	def remove_slash(str)
		arr = str.split('/')
		ret = arr.first
		arr.delete_at(0)
		arr.each { |s|
			if s != ''
				ret += "/#{s}"
			end
		}
		ret
	end

	def initialize(dir)
		@compiler = "cc"
		@sysroot = ''
		@target = ''
		@mach = ''
		@position_independent_code = false
		@flags = MCBuild.detect_machine_macro + " -Wno-unused-command-line-argument"

		@archiver = "ar"

		@d = remove_slash(dir)

		@name = "mcdefault"

		@fext = ".c"
		@oext = ".o"
		@aext = ".a"
		@std  = "c99"
		@outpath = "_build"

		@headers    = []
		@excludes   = []
		@dependency = []

		@include_path = "#{@d}/#{@outpath}/archive/include"
		@lib_path     = "#{@d}/#{@outpath}/archive/lib"

		@compile_arg = " -I#{self.export_include_path}"
		@link_arg    = " -L#{self.export_lib_path}"
	end

	def export_include_path
		@include_path
	end

	def export_lib_path
		@lib_path
	end

	def name
		@name
	end

	def headers
		@headers
	end

	def excludes
		@excludes
	end

	def set_export_include_path(incpath)
		@include_path = incpath
		self
	end

	def set_export_lib_path(libpath)
		@lib_path = libpath
		self
	end

	def set_compiler(compiler)
		@compiler = compiler
		self
	end

	def set_archiver(archiver)
		@archiver = archiver
		self
	end

	def set_sysroot(root)
		@sysroot = root
		self
	end

	def set_position_independent_code(pic)
		@position_independent_code = pic
		self
	end

	def set_headers(headers)
		@headers = headers
		self
	end

	def set_name(name)
		@name = name
		self
	end

	def set_fext(fext)
		@fext = fext
		self
	end

	def set_oext(oext)
		@oext = oext
		self
	end

	def set_aext(aext)
		@aext = aext
		self
	end

	def set_target(target)
		@target = target
		self
	end

	def set_arch(arch)
		@mach = arch
		self
	end

	def set_std(std)
		@std = std
		self
	end
	
	def set_flags(flags)
		@flags = flags
		self
	end

	def add_flag(flag)
		@flags += ' ' + flag
		self
	end

	def set_outpath(outpath)
		@outpath = outpath
		self
	end

	def set_excludes(excludes)
		@excludes = Array.new(excludes)
		self
	end

	def disable_warning(warning)
		@flags += ' -Wno-' + warning
		self
	end

	def disable_warnings(warnings)
		warnings.each { |warn|
			self.disable_warning(warn)
		}
		self
	end

	def enable_warning(warning)
		@flags += ' -W' + warning
		self
	end

	def enable_warnings(warnings)
		warnings.each { |warn|
			self.enable_warning(warn)
		}
		self
	end

	def info
		puts "Monk-C compiler use settings:"
		puts "--------------------------------"
		puts "         CPU target -> #{@target}"
		puts "         C standard -> #{@std}"
		puts "               name -> #{@name}"
		puts "           compiler -> #{@compiler}"
		puts " filename extension -> #{@fext}"
		puts "   output extension -> #{@oext}"
		puts "  archive extension -> #{@aext}"
		puts "      compile flags -> #{@flags}"
		puts "         source dir -> #{@d}"
		puts "           excludes -> #{self.excludes}"
		puts "--------------------------------"
		puts "C compiler infos:"
		puts "--------------------------------"
		system("#{@compiler} --version")
		puts "--------------------------------"
		self
	end

	def clean
		MCBuild.clean("#{@d}/#{@outpath}")
		self
	end

	def prepare
		begin
			FileUtils.rm_rf   "#{@d}/#{@outpath}"
			FileUtils.mkdir_p "#{@d}/#{@outpath}/archive/include"
			FileUtils.mkdir_p "#{@d}/#{@outpath}/archive/lib"
			if @headers.count != 0
				self.copy_headers
			else
				self.copy_headers_all
			end
		rescue Exception => e
			puts e
		end
		self
	end

	def set_dependency(libs=[])
		libs.each { |lib|
			@compile_arg += " -I#{lib.export_include_path} -L#{lib.export_lib_path} -l#{lib.name}"
			@link_arg    += " -I#{lib.export_include_path} -L#{lib.export_lib_path} -l#{lib.name}"
		}
		self
	end

	def prehash(string)
		self
	end

	def copy_headers
		begin
			Find.find(@d) { |header|
				base = File.basename(header)
				if @headers.include? base
					puts "copying-> #{header}"
					FileUtils.cp("#{header}", "#{@d}/#{@outpath}/archive/include")
				end
			}
		rescue Exception => e
			puts e
		end
		self
	end

	def copy_headers_all(except=[])
		begin
			Find.find(@d) { |header|
				ext = File.extname(header)
				base = File.basename(header)
				if (ext == ".h") && (!header.include? self.export_include_path)
					if (except != nil) && (except.include? base)
						puts "except: #{base}"
					else
						puts "copying-> #{header}"
						FileUtils.cp("#{header}", self.export_include_path)
					end
				end
			}
		rescue Exception => e
			puts e
		end
		self
	end

	def compiler_command
		cmd = @compiler
		cmd += " -std=#{@std}"
		if @sysroot != ''
			cmd += " --sysroot #{@sysroot}"
		end
		if @target != ''
			cmd += " -target #{@target}"
		end
		if @mach != ''
			cmd += " -arch #{@mach}"
		end
		if @position_independent_code
			cmd += " -fPIC"
		end
		cmd += " #{@flags}"
		cmd
	end

	def linker_command
		cmd = @compiler
		if @sysroot != ''
			cmd += " --sysroot #{@sysroot}"
		end
		if @target != ''
			cmd += " -target #{@target}"
		end
		if @mach != ''
			cmd += " -arch #{@mach}"
		end
		cmd
	end

	def archiver_command
		cmd = @archiver
	end

	def compile_file(file)
		ext = File.extname(file)
		base = File.basename(file, ext)
		cmd = compiler_command
		cmd += " -c -o #{@d}/#{@outpath}/#{base}#{@oext} #{file} #{@compile_arg}"
		#puts(cmd)
		system(cmd)
		self
	end

	def compile
		self.clean
		self.prepare
		begin
			Find.find(@d) { |file|
				ext = File.extname(file)
				base = File.basename(file, ext)
				if ext == ".c" || ext == ".asm" || ext == ".S"
					if (@excludes != nil) && (@excludes.include? base)
						puts "exclude: #{base}"
					else
						compile_file(file)
					end
				end
			}
		rescue Exception => e
			puts "Error[#{@d}]: " + e.to_s
		end
		self
	end

	def archive_lib
		cmd = "#{self.archiver_command} -r #{self.export_lib_path}/lib#{@name}#{@aext} #{@d}/#{@outpath}/*#{@oext}"
		#puts(cmd)
		system(cmd)
		self
	end

	def archive_so
		if @position_independent_code
			cmd = "#{self.compiler_command} -shared -Wl,-soname,lib#{@name}.so"
			cmd += " -o #{self.export_lib_path}/lib#{@name}.so #{@d}/#{@outpath}/*#{@oext}"
			cmd += " -Wl,--whole-archive #{@link_arg} -Wl,--no-whole-archive"
			#puts(cmd)
			system(cmd)
			self
		else
			puts "Error[#{@d}]: please use set_shared(true) before archive so"
			nil
		end
	end

	def archive_exe
		cmd = "#{self.linker_command} -o #{self.export_lib_path}/#{@name} #{@d}/#{@outpath}/*#{@oext} #{@link_arg}"
		#puts(cmd)
		system(cmd)
		self
	end

	def copy_lib_to(path)
		begin
			FileUtils.mkdir_p("#{@d}/#{path}")
			FileUtils.cp("#{self.export_lib_path}/lib#{@name}#{@aext}", "#{@d}/#{path}")
		rescue Exception => e
			puts "Error[#{@d}]: " + e.to_s
		end
		self
	end

	def copy_so_to(path)
		begin
			FileUtils.mkdir_p("#{@d}/#{path}")
			FileUtils.cp("#{self.export_lib_path}/lib#{@name}.so", "#{@d}/#{path}")
		rescue Exception => e
			puts "Error[#{@d}]: " + e.to_s
		end
		self
	end

	def run
		system("#{self.export_lib_path}/#{name}")
	end

	def done
		puts "---------- build finished ----------"
		puts "#{self.export_lib_path}/#{name}"
	end
end

#test area
=begin
lib = MCBuild.new('../example/mylib')
	.set_name("lib")
	.set_headers(["mylib.h"])
	.info
	.compile
	.archive_lib

exp = MCBuild.new('../example/myapp')
	.set_name("exp")
	.set_dependency([lib])
	.info
	.compile
	.archive_exe
	.run
=end



