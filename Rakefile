require "rake/clean"

CLEAN.include "*~"
CLEAN.include "*.o"
CLEAN.include "rkit"

CLOBBER.include "rkit.app"

ENV["CC"] ||= "gcc"
LIBS = "-llua"
SOURCES = Dir["*.c"] + Dir["*.m"]
OBJECTS = SOURCES.map{|s| s.ext(".o")}
FLAGS = "-g -arch i386"
FRAMEWORKS = %w{Foundation AppKit QuartzCore}

OBJECTS.map{|o| file o => (File.exists?(o.ext(".c")) ? o.ext(".c") : o.ext(".m"))}
OBJECTS.map{|o| file o => (Dir["*.h"])}

task :default => :bundle

file "rkit" => OBJECTS do
    frameworks = FRAMEWORKS.map{|f| "-framework #{f}" }.join(" ")
    sh "#{ENV['CC']} #{FLAGS} -o rkit #{OBJECTS.join(' ')} #{LIBS} #{frameworks}"
end

task :bundle => "rkit" do
    sh "mkdir -p rkit.app/Contents/MacOS"
    sh "cp rkit rkit.app/Contents/MacOS/"
end

task :run => :bundle do
    exec "rkit.app/Contents/MacOS/rkit"
end

task :gdb => :bundle do
    exec "gdb rkit.app/Contents/MacOS/rkit"
end

rule ".o" => ".c" do |t|
    sh "#{ENV['CC']} #{FLAGS} -o #{t.name} -c #{t.source}"
end

rule ".o" => ".m" do |t|
    sh "#{ENV['CC']} #{FLAGS} -o #{t.name} -c #{t.source} -D OBJC"
end
