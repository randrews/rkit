ENV["CC"] ||= "gcc"
LIBS = "-llua -lncurses"
SOURCES = Dir["*.c"]
OBJECTS = SOURCES.map{|s| s.ext(".o")}

OBJECTS.map{|o| task o => o.ext(".c")}

task :default => OBJECTS do
    sh "#{ENV['CC']} -o cave main.o #{LIBS}"
end

rule ".o" => ".c" do |t|
    sh "#{ENV['CC']} -o #{t.name} -c #{t.source}"
end
