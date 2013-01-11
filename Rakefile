require 'xcoder/rake_task'
require 'open4'

class String
	def self.colorize(text, color_code)
	"\e[#{color_code}m#{text}\e[0m"
	end

	def red
		self.class.colorize(self, 31);
	end

	def green
		self.class.colorize(self, 32);
	end

	def yellow
		self.class.colorize(self, 33);
	end

	def cyan
		self.class.colorize(self, 36);
	end
end

class Runner
	def self.instance 
		@instance ||= Runner.new
	end

	def execute(title, command)
		puts title.green
		status = Open4::popen4(command) do |pid, stdin, stdout, stderr| 
      	
      		stderr.each_line do |line|
	        	puts line.red
      		end
    	end
    	return status.exitstatus    
	end

end

namespace :tools do

	desc "Setup project for development"
	task :setup do
		Runner.instance.execute("Loading git submodules...", "git submodule update --init --recursive")
		puts "\nComplete.".green
	end
	
end

namespace :build do 

	desc "Build Sample"
	task :sample do
		config = Xcode.project('JJAFAcceleratedDownloadRequestOperation-Sample').target('JJAFAcceleratedDownloadRequestOperation-Sample').config(:Debug)
		builder = config.builder
		builder.clean
		builder.build :sdk => :iphonesimulator
	end

end
