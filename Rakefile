require "rake/clean"

CLEAN.include "*~"
CLEAN.include "*.o"
CLEAN.include "rkit"

ENV["CC"] ||= "gcc"
LIBS = "-llua"
SOURCES = Dir["*.c"]
OBJECTS = SOURCES.map{|s| s.ext(".o")}
FLAGS = "-g -arch i386"

OBJECTS.map{|o| task o => o.ext(".c")}

ALLEGRO_LIBS = `allegro-config --libs`
ALLEGRO_FLAGS = `allegro-config --cflags`

task :default => OBJECTS do
    sh "#{ENV['CC']} #{FLAGS} -o rkit #{OBJECTS.join(' ')} #{LIBS} #{ALLEGRO_LIBS}"
end

rule ".o" => ".c" do |t|
    sh "#{ENV['CC']} #{FLAGS} -o #{t.name} -c #{t.source} #{ALLEGRO_FLAGS}"
end
