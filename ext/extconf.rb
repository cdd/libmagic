require 'mkmf'
$LDFLAGS = "-lmagic -lstdc++"
$CFLAGS = "-Wall"
if !have_library('magic')
  puts "libmagic required -- not found. It can be installed via MacPorts: port install file."
  exit 1
end
create_makefile('libmagic_wrapper')
