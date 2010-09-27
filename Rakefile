ENV["CC"] ||= "gcc"
LIBS = "-llua -lncurses"
SOURCES = Dir["*.c"]
OBJECTS = SOURCES.map{|s| s.ext(".o")}
FLAGS = "-arch i386"

OBJECTS.map{|o| task o => o.ext(".c")}

task :default => OBJECTS do
    sh "#{ENV['CC']} #{FLAGS} -o cave #{OBJECTS.join(' ')} #{LIBS}"
end

rule ".o" => ".c" do |t|
    sh "#{ENV['CC']} #{FLAGS} -o #{t.name} -c #{t.source}"
end
