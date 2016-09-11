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

	def self.noArgs(valid_args)
		ARGV.each { |arg|
			valid_args.each { |va|
				if va == arg
					return
				end
			}
		}
		yield valid_args
	end

	def self.printArgs(valid_args)
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
	end
 
	def self.waitArg(arg)
		ARGV.each do |_arg|
			if _arg==arg
				yield
			end
		end
	end

	def self.clean(path)
		begin
			FileUtils.rm_rf(path)
		rescue Exception => e
			puts e
		end
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
		@target = ''
		@mach = ''
		@flags = MCBuild.detect_machine_macro

		@d = remove_slash(dir)

		@name = "mcdefault"
		@fext = ".c"
		@oext = ".o"
		@aext = ".a"
		@std  = "c99"
		@outpath = "_build"

		@headers = []
		@excludes = []
		@dependency = []

		@compile_arg = " -I#{self.export_path}"
		@link_arg    = " -L#{self.export_path}"
	end

	def export_path
		"#{@d}/#{@outpath}/archive"
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

	def set_outpath(outpath)
		@outpath = outpath
		self
	end

	def set_excludes(excludes)
		@excludes = Array.new(excludes)
		self
	end

	def info
		puts "Monk-C compiler use settings:"
		puts "--------------------------------"
		puts "         CPU target -> #{@target}"
		puts "         C standard -> #{@std}"
		puts "               name -> #{@name}"
		puts " filename extension -> #{@fext}"
		puts "   output extension -> #{@oext}"
		puts "  archive extension -> #{@aext}"
		puts "      compile flags -> #{@flags}"
		puts "         source dir -> #{@d}"
		puts "         export dir -> #{self.export_path}"
		puts "           excludes -> #{self.excludes}"
		puts "--------------------------------"
		puts "C compiler infos:"
		puts "--------------------------------"
		system("cc --version")
		puts "--------------------------------"
		self
	end

	def clean
		MCBuild.clean("#{@d}/#{@outpath}")
		self
	end

	def prepare
		begin
			FileUtils.rm_rf("#{@d}/#{@outpath}")
			FileUtils.mkdir_p "#{@d}/#{@outpath}/archive"
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
			path = lib.export_path
			name = lib.name

			@compile_arg += " -I#{path}"
			@link_arg    += " -L#{path}"
			@link_arg    += " -l#{name}"
		}
		@link_arg += @compile_arg
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
					FileUtils.cp("#{header}", "#{@d}/#{@outpath}/archive")
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
				if (ext == ".h") && (!header.include? self.export_path)
					if (except != nil) && (except.include? base)
						puts "except: #{base}"
					else
						puts "copying-> #{header}"
						FileUtils.cp("#{header}", self.export_path)
					end
				end
			}
		rescue Exception => e
			puts e
		end
		self
	end

	def compiler_command
		cmd = "cc"
		if @target != ''
			cmd += " -target #{@target}"
		end
		if @mach != ''
			cmd += " -arch #{@mach}"
		end
		cmd += " -std=#{@std}"
		cmd += " #{@flags}"
		cmd
	end

	def linker_command
		cmd = "cc"
		if @target != ''
			cmd += " -target #{@target}"
		end
		if @mach != ''
			cmd += " -arch #{@mach}"
		end
		#cmd += " -std=#{@std}"
		#cmd += " #{@flags}"
		cmd
	end

	def compile_file(file)
		base = File.basename(file, ".c")
		cmd = compiler_command
		cmd += " -c -o #{@d}/#{@outpath}/#{base}#{@oext} #{file} #{@compile_arg}"
		puts(cmd)
		system(cmd)
		self
	end

	def compile
		self.clean
		self.prepare
		begin
			Find.find(@d) { |file|
				ext = File.extname(file)
				base = File.basename(file)
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
		cmd = "ar -r #{@d}/#{@outpath}/archive/lib#{@name}#{@aext} #{@d}/#{@outpath}/*#{@oext}"
		puts(cmd)
		system(cmd)
		self
	end

	def archive_exe
		cmd = linker_command
		cmd += " -o #{@d}/#{@outpath}/archive/#{@name} #{@d}/#{@outpath}/*#{@oext} #{@link_arg}"
		puts(cmd)
		system(cmd)
		self
	end

	def run
		system("#{self.export_path}/#{name}")
	end

	def done
		puts "---------- build finished ----------"
		puts "#{self.export_path}/#{name}"
	end
end

#test area
=begin
runt = MCBuild.new('../../../mcruntime')
	.set_name("monkc")
	.set_headers(["monkc.h"])
	.set_excludes(["MCNonLock.S"])
	.info
	.compile
	.archive_lib

lmt = MCBuild.new('../../../lemontea')
	.set_name("lemontea")
	.set_dependency([runt])
	.info
	.compile
	.archive_lib

exp = MCBuild.new('../../../example')
	.set_name("exp")
	.set_dependency([runt, lmt])
	.info
	.compile
	.archive_exe
	.run
=end



