require "rake/clean"

CLEAN.include "*~"
CLEAN.include "*.o"
CLEAN.include "rkit"

ENV["CC"] ||= "gcc"
LIBS = "-llua"
SOURCES = Dir["*.c"] + Dir["*.m"]
OBJECTS = SOURCES.map{|s| s.ext(".o")}
FLAGS = "-g -arch i386"
FRAMEWORKS = %w{Foundation AppKit}

OBJECTS.map{|o| task o => (File.exists?(o.ext(".c")) ? o.ext(".c") : o.ext(".m"))}

task :default => OBJECTS do
    frameworks = FRAMEWORKS.map{|f| "-framework #{f}" }.join(" ")
    sh "#{ENV['CC']} #{FLAGS} -o rkit #{OBJECTS.join(' ')} #{LIBS} #{frameworks}"
end

rule ".o" => ".c" do |t|
    sh "#{ENV['CC']} #{FLAGS} -o #{t.name} -c #{t.source}"
end

rule ".o" => ".m" do |t|
    sh "#{ENV['CC']} #{FLAGS} -o #{t.name} -c #{t.source} -D OBJC"
end
