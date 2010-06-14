# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

JSMIN_EXEC = File.dirname(__FILE__) + "/ext/jsmin.rb"
CACHE_FILE = "jquery.syntax.cache.js"
MINIFIED_FILE = "jquery.syntax.min.js"
LICENSE = <<EOF
// This file is part of the "jQuery.Syntax" project, and is licensed under the GNU AGPLv3.
// Copyright 2010 Samuel Williams. All rights reserved.
// For more information, please see <http://www.oriontransfer.co.nz/software/jquery-syntax>
EOF

require 'tasks/rails'

task :clean_css do
	Dir.glob(File.join(File.dirname(__FILE__), "jquery.syntax.*.css")) do |path|
		FileUtils.rm path, :verbose => true
	end
end

task :generate_css, [:theme,:override,:output] => [:clean_css] do |task, arguments|
	theme = arguments[:theme] || "clean"
	override = arguments[:override] || "master.sass"
	
	puts "Building CSS: #{theme}/#{override}"
	
	output = arguments[:output] || File.dirname(__FILE__)
	
	unless File.directory?(theme)
		theme = File.join(File.dirname(__FILE__), "themes", theme)
	end
	
	unless File.directory?(theme)
		$stderr.puts "Could not find theme #{theme}!"
		exit 1
	end
	
	unless File.exist?(override)
		override = File.join(theme, override)
	end
	
	unless File.exist?(override)
		$stderr.puts "Could not find master/override #{override} in #{theme}."
	end
	
	Dir.glob(File.join(theme, "jquery.syntax.*.sass")) do |sass|
		output_path = File.join(output, File.basename(sass, ".sass") + ".css")
		
		puts "sass -I #{theme.dump} --stdin #{output_path}"
		
		IO.popen("sass -I #{theme.dump} --stdin #{output_path}", "w") do |io|
			io.puts("@import #{override}")
			io.puts("@import #{File.basename(sass)}")
			io.close_write
		end
	end
	
	Rake::Task[:update_aliases].reenable
	Rake::Task[:update_aliases].invoke
end

# This builds a combined jquery.syntax.js and jquery.syntax.cache.js and minifies the result
task :build_combined => [:update_aliases] do
	IO.popen(JSMIN_EXEC, "r+") do |min|
		["jquery.syntax.js", "jquery.syntax.cache.js"].each do |path|
			min.write(File.read(path))
		end
	
		min.close_write
	
		buf = min.read
	
		File.open(MINIFIED_FILE, "w") do |fp|
			fp.write(LICENSE)
			fp.write(buf)
		end
	end
end

# Note... this is one way !
task :compress_all => [:build_combined] do
	files = Dir[File.dirname(__FILE__) + "/jquery.syntax.*.js"]
	
	files.each do |path|
		IO.popen(JSMIN_EXEC, "r+") do |min|
			min.write(File.read(path))
			
			min.close_write
			
			File.open(path, "w") do |fp|
				fp.write(LICENSE)
				fp.write(min.read)
			end
		end
	end
end

task :default => :build_combined

