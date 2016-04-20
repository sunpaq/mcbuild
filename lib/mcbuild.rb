#!/usr/bin/ruby
require 'find'
require 'fileutils'

class MCBuild
	def self.waitArg(arg)
		ARGV.each do |_arg|
			if _arg==arg
				yield 
			else
				puts "usage: ./script.rb #{arg}"
			end
		end
	end

	def remove_slash(str)
		if str=='./'
			@d = '.'
		else
			@d = str
		end
	end

	def initialize(dir, fext=".c", oext=".o", aext=".a", 
		mach="x86_64", std="c99", 
		outpath="_build")

		remove_slash(dir)

		@fext = fext
		@oext = oext
		@aext = aext
		@mach = mach
		@std = std
		@outpath = outpath
	end

	def set_arch(arch)
		@mach = arch
		self
	end

	def info
		puts "Monk-C compiler use settings:"
		puts "--------------------------------"
		puts "           CPU Arch -> #{@mach}"
		puts "         C standard -> #{@std}"
		puts " filename extension -> #{@fext}"
		puts "   output extension -> #{@oext}"
		puts "  archive extension -> #{@aext}"
		puts "--------------------------------"
		puts "C compiler infos:"
		puts "--------------------------------"
		system("cc --version")
		puts "--------------------------------"
	end

	def clean
		begin
			FileUtils.rm_rf("#{@d}/#{@outpath}")
		rescue Exception => e
			puts e
		end
	end

	def prepare(libpath=[], libs=[])
		@compile_arg = " -I#{@d}/#{@outpath}/archive"
		@link_arg    = " -L#{@d}/#{@outpath}/archive"

		libpath.each { |path|
			@compile_arg += " -I#{path}"
			@link_arg += " -L#{path}"
		}

		libs.each { |lib|
			@link_arg += " -l#{lib}"
		}

		@link_arg += @compile_arg

		begin
			FileUtils.rm_rf("#{@d}/#{@outpath}")
			FileUtils.mkdir_p "#{@d}/#{@outpath}/archive"
		rescue Exception => e
			puts e
		end
	end

	def prehash(string)
		
	end

	def copy_headers(headers)
		begin
			headers.each { |header|
				puts "copying-> #{@d}/#{header}"
				FileUtils.cp("#{@d}/#{header}", "#{@d}/#{@outpath}/archive")
			}
		rescue Exception => e
			puts e
		end
	end

	def compile_file(file)
		base = File.basename(file, ".c")
		cmd = "cc -arch #{@mach} -std=#{@std} -c -o #{@d}/#{@outpath}/#{base}#{@oext} #{file} #{@compile_arg}"
		puts(cmd)
		system(cmd)
	end

	def compile(path=@d)
		Find.find(path) { |file|
			if File.extname(file) == ".c" || File.extname(file) == ".asm"
				compile_file(file)
			end
		}
	end

	def archive_lib(name)
		cmd = "ar -r #{@d}/#{@outpath}/archive/#{name} #{@d}/#{@outpath}/*#{@oext}"
		puts(cmd)
		system(cmd)
	end

	def archive_exe(name)
		cmd = "cc -o #{@d}/#{@outpath}/archive/#{name} #{@d}/#{@outpath}/*#{@oext} #{@link_arg}"
		puts(cmd)
		system(cmd)
	end
end



